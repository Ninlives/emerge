from qutebrowser.api import cmdutils, message
from subprocess import call

acl_proxy    = 'socks://@sPROXY_ADDRESS@:@sACL_PORT@'
global_proxy = 'socks://@sPROXY_ADDRESS@:@sLOCAL_PORT@'

@cmdutils.register()
def toggle_proxy():
    if c.content.proxy == global_proxy:
        c.content.proxy = acl_proxy
        message.info(f"Switch to acl proxy: {acl_proxy}")
    elif c.content.proxy == acl_proxy:
        c.content.proxy = 'none'
        message.info(f"Switch proxy to none")
    else:
        c.content.proxy = global_proxy
        message.info(f"Switch to global proxy: {global_proxy}")

call(['@sKEYCTL@', 'new_session', 'qute'])
