#!/usr/bin/python

from ansible.module_utils.basic import AnsibleModule
import os
import signal

def main():
    module_args = dict(
        pid=dict(type='int', required=True),
        debug=dict(type='bool', required=False, default=False)
    )

    module = AnsibleModule(argument_spec=module_args, supports_check_mode=False)
    pid = module.params['pid']
    debug = module.params['debug']

    if debug:
        module.exit_json(changed=False, msg=f"this process {pid} will be killed (debug mode)")

    try:
        os.kill(pid, signal.SIGKILL)
        module.exit_json(changed=True, msg=f"Process {pid} was killed successfully.")
    except ProcessLookupError:
        module.exit_json(changed=False, msg=f"Process {pid} not found.")
    except PermissionError:
        module.fail_json(msg=f"Permission denied to kill process {pid}.")
    except Exception as e:
        module.fail_json(msg=f"Unexpected error: {str(e)}")

if __name__ == '__main__':
    main()

