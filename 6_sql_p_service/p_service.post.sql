CREATE OR REPLACE FUNCTION p_service.post(p_uri character varying, p_request_body json, p_paramenters json DEFAULT '[]'::json, p_decode character varying DEFAULT ''::character varying)
 RETURNS json
 LANGUAGE plpython3u
AS $function$
from urllib.request import Request, urlopen
from urllib.error import URLError, HTTPError

clen = len(p_paramenters)
req = Request(p_uri, p_paramenters, {'Content-Type': 'application/json', 'Content-Length': clen})
try:
    response = urlopen(req, p_request_body.encode('utf-8'))
except HTTPError as e:
     print('Oops. HTTP Error occured')
     print('Response is: {content}'.format(content = e.response.content))
     print('Error code: ', e.code)    
except URLError as e:
    print('We failed to reach a server.')
    print('Reason: ', e.reason)
else:    
    if p_decode == '':
        data = response.read()
    else:    
        data = response.read().decode(p_decode)
     
return data  
     
$function$
;
