FROM solidtime/solidtime:0.17.0

COPY --chmod=755 init.sh /init.sh

CMD ["/init.sh"]
