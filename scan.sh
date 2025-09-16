#!/usr/bin/env bash
set -uo pipefail

OUT_DIR="${OUT_DIR:-$PWD/scans}"
JSON_DIR="$OUT_DIR/json"
TABLE_DIR="$OUT_DIR/table"
SUMMARY="$OUT_DIR/summary.csv"

mkdir -p "$JSON_DIR" "$TABLE_DIR"

# Обновляем БД уязвимостей заранее
echo "==> Updating Trivy DB..."
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$OUT_DIR":/out aquasec/trivy:latest \
  image --download-db-only --cache-dir /out/.trivycache

IMAGES=(
  # Backend
  golang:1.23
  golang:1.3
  golang:1.5.3
  # Analytics
  python:3.12.6-alpine3.19
  python:3.8.20-alpine3.19
  python:3.8.20-bookworm
  # Frontend
  nginx:1.27.1
  httpd:2.4.62
)

# Заголовок сводной таблицы
echo "image,CRITICAL,HIGH,MEDIUM,LOW,UNKNOWN,total" > "$SUMMARY"

for img in "${IMAGES[@]}"; do
  safe_name=$(echo "$img" | tr ':/' '__')
  echo "==> Pull $img"
  if ! docker pull "$img"; then
    echo "Ошибка: не удалось подтянуть образ $img, пропускаем."
    continue
  fi

  echo "==> Scan $img (JSON + table)"
  if ! docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$OUT_DIR":/out aquasec/trivy:latest \
      image --cache-dir /out/.trivycache --scanners vuln --format json --ignore-unfixed=false \
      --vuln-type=os,library "$img" > "$JSON_DIR/${safe_name}.json"; then
    echo "Ошибка при JSON-сканировании $img, пропускаем."
    continue
  fi

  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$OUT_DIR":/out aquasec/trivy:latest \
      image --cache-dir /out/.trivycache --scanners vuln --format table --ignore-unfixed=false \
      --vuln-type=os,library "$img" > "$TABLE_DIR/${safe_name}.txt" || echo "Ошибка при генерации таблицы $img"

  # Быстрые счётчики по severity через jq
  counts=$(jq -r '
    [ .Results[]?.Vulnerabilities[]? ] 
    | group_by(.VulnerabilityID) 
    | map(.[0]) 
    | group_by(.Severity) 
    | map({(.[0].Severity): length}) 
    | add // {}
  ' "$JSON_DIR/${safe_name}.json" 2>/dev/null || echo "{}")

  get_count () { echo "$counts" | jq -r --arg k "$1" '.[$k] // 0'; }

  c=$(get_count CRITICAL)
  h=$(get_count HIGH)
  m=$(get_count MEDIUM)
  l=$(get_count LOW)
  u=$(get_count UNKNOWN)
  total=$((c+h+m+l+u))

  echo "${img},${c},${h},${m},${l},${u},${total}" >> "$SUMMARY"
done

echo
echo "Готово."
echo "JSON отчёты:    $JSON_DIR"
echo "Табличные отчёты $TABLE_DIR"
echo "Сводка (CSV):    $SUMMARY"

