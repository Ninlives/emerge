import sys
import requests
from pprint import pprint
from dateutil.relativedelta import relativedelta
from dateutil.utils import today
from dateutil.tz import UTC

host = sys.argv[1]
token_file = sys.argv[2]

end_time = today(tzinfo=UTC) + relativedelta(days=7)
session = requests.session()
session.verify = '/etc/ssl/certs/ca-bundle.crt'

with open(token_file, mode='r') as f:
    token = f.read()

reservations = session.get(
                f"https://onecloudapi.{host}/{token}/myreservations"
               ).json()
for reservation in reservations:
    res = session.put(f"https://onecloudapi.{host}/reservation", json={
                'reservationid': reservation['reservationid'],
                'starttime': reservation['starttime'],
                'endtime': end_time.isoformat(),
                'systemid': reservation['systemid'],
                'token': token
            })
    pprint(res.json())
