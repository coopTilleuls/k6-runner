FROM grafana/xk6:0.12.1 as builder
RUN xk6 build  --with  github.com/grafana/xk6-redis  --with github.com/grafana/xk6-output-prometheus-remote

FROM alpine:3.18 as release
RUN adduser -D -u 12345 -g 12345 k6
COPY --from=builder /xk6/k6 /usr/bin/k6
USER k6
WORKDIR /home/k6
ENTRYPOINT ["k6"]
