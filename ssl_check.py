import argparse
import ssl
from http.server import HTTPServer, BaseHTTPRequestHandler

DEFAULT_PORT = 443
HOST = '0.0.0.0'


def main():
    parser = argparse.ArgumentParser(
        description='Check ssl certificates validity'
    )
    parser.add_argument('keyfile', type=str,
                        help='Path to private key file')
    parser.add_argument('certfile',
                        help='Path to certfile')
    parser.add_argument('--port', type=int, default=DEFAULT_PORT,
                        help='Port that server should listen')
    args = parser.parse_args()

    httpd = HTTPServer((HOST, args.port), BaseHTTPRequestHandler)
    httpd.socket = ssl.wrap_socket(
        httpd.socket,
        keyfile=args.keyfile,
        certfile=args.certfile, server_side=True)
    httpd.serve_forever()


if __name__ == '__main__':
    main()
