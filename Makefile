DESTDIR=/usr/local
BINDIR=$(DESTDIR)/sbin
SYSTEMDIR=$(DESTDIR)/lib/systemd/system

install: unitA unitB 
	for i in $+; do make _install TARGET=$$i; done

_install: $(BINDIR)/$(TARGET) $(SYSTEMDIR)/$(TARGET).service

_restart:
	systemctl daemon-reload

# まだユニットファイルが配置されてないときがあるのでそのときは再起動指示を出さないので注意
$(BINDIR)/$(TARGET): $(TARGET)
	install -d -m 0755 -o root -g root $(@D)
	install -m 0755 -o root -g root $< $@
	-[ -f $(SYSTEMDIR)/$(TARGET).service ] && make _restart TARGET=$(TARGET)

$(SYSTEMDIR)/$(TARGET).service : $(TARGET).service
	install -d -m 0755 -o root -g root $(@D)
	install -m 0444 -o root -g root $< $@
	make _restart TARGET=$(TARGET)

clean:
	set -x ; for i in A B; do \
		P=unit$$i; U=$$P.service; \
		if [ -f $(SYSTEMDIR)/$(TARGET).service ]; then \
			systemctl is-active $$U && systemctl stop $$U; \
			systemctl is-enabled $$U && systemctl disable $$U; \
		fi; \
		sudo rm -vf $(SYSTEMDIR)/$$U $(BINDIR)/$$P; \
	done
