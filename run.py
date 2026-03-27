from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

PORT = 8000

class SABHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        # Required for SharedArrayBuffer
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")

        # Optional but recommended
        self.send_header("Cross-Origin-Resource-Policy", "same-origin")

        super().end_headers()

if __name__ == "__main__":
    server = ThreadingHTTPServer(("0.0.0.0", PORT), SABHandler)
    print(f"Serving on http://localhost:{PORT}")
    server.serve_forever()