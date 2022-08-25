FROM cr.loongnix.cn/library/busybox:1.30.1

ADD operator /bin/operator

# On busybox 'nobody' has uid `65534'
USER 65534

ENTRYPOINT ["/bin/operator"]
