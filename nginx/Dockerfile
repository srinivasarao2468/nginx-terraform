FROM nginx:1.25-alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Copy custom config
COPY phrase.conf /etc/nginx/conf.d/phrase.conf

# Healthcheck for container
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1/phrase || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]