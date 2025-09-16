Описание работы с нодами!

1. Создается виртальная машина
2. Создается отдельный диск и монтируется в директорию /mnt/data
3. ```lsblk```
4. ```sudo parted /dev/sdb```

       (parted) mklabel gpt
       (parted) mkpart primary ext4 0% 100%
       (parted) quit

5. ```sudo mkfs.ext4 /dev/sdb1```
6. ```mkdir /mnt/data```
7. ```mount /dev/sdb1 /mnt/data```
8. Чтоб при перезагрузки раздел монтировался 
```
blkid 
Находим тот раздел который нам надо монтировать

nano /etc/fstab
UUID=f51346c3-a921-4e04-a109-8740abaf92bc /mnt/data ext4 defaults 0 2
```