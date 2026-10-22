# Serve the PWA manifest with its proper type (Rack doesn't know .webmanifest).
Rack::Mime::MIME_TYPES[".webmanifest"] = "application/manifest+json"
