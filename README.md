# Wazuh Yara Entegrasyonu

Gerekli dosyalar repo icinde mevcut
### Wazuh sunucu tarafi

Yara kurallarinin wazuh'a tanimlanmasi icin asagidaki dosyalara eklemeler yapilir
  - vim /var/ossec/etc/rules/local_rules.xml
  - vim /var/ossec/etc/decoders/local_decoder.xml
  - vim /var/ossec/etc/ossec.conf

##### Restart the wazuh server
systemctl restart wazuh-dashboard; systemctl restart wazuh-indexer; systemctl restart wazuh-manager.service

### Wazuh agent tarafi
Oracle Linux 8 icin;
  - yum install yara jq
  - mkdir /var/ossec/yara_rules/ 
  - add /var/ossec/yara_rules/yara_rules.yar
  - add /var/ossec/active-response/bin/yara.sh
  - chmod +x /var/ossec/active-response/bin/yara.sh

##### Oracle 7 icin ek (dosya sahipligi ile ilgili degisiklik gerekiyor)
  - chown root:wazuh /var/ossec/active-response/bin/yara.sh
  - chmod 750  /var/ossec/active-response/bin/yara.sh
  - systemctl restart wazuh-agent.service

### Ansible ile wazuh agent'lari guncelleme
Bu playbook sadece yara kurallari guncellendiginde sunuculara dagitim yapacak. Boylece gereksiz yere tum sunucularin kural guncellemek icin trafik yapmasina gerek olmayacak.

- Ansible sunucuda valhalla-cli kurulu olmasi gerekiyor (pip3 install valhallaAPI)
- wazuh server'da yaratest adiyla bir grup olmali ve yara betiginin calismasini bekledigimiz sunucular buraya dahil olmali
- Playbook'un (yara_update.yml) yaptigi:
    -  ansible host "valhalla-cli -o yara_rules-{{today_str}}.yar" komutu ile bugunun tarihi ile kural dosyasini indiriyor
    -  Kural dosyasinda dunden bugune degisiklik var mi kontrol ediyor
    -  Fark varsa eicar ile kural dosyasinin calisabilirligini test ediyor
    -  yara.yar dosyasini wazuh sunucunun /var/ossec/etc/shared/yaratest dizinine birakiyor. Burada wazuh'un dosya paylasim ozelligini kullaniyoruz. 
    -  Client tarafinda yara kurallari yarac ile derleniyor. Bu sayede tarama islemi daha hizli yapiliyor (Not: Farkli versyona sahip yara programlari birbirinin derledigi yara kurallarini kullanamiyor, o nedenle her suncu kendi kuralini derliyor)

- Burada daha kolay bir yontem izlenebilirdi ama cok fazla sunucuda cron tanimlamak gerekirdi, tercih etmedim;
  - wazuh sunucuya valhalla-cli kurulur ve ilgili wazuh dizinine yara kurallari indirilir. (cron-1) (Valhalla her indirmede kural eklenmemiş olsa da Retrieved bilgisini degistiriyor: Gereksiz ic trafik)
  - butun sunuculara yara kurallarini guncellemesi ve gerekli yere koyulmasi icin cron girilir (cron-2) 




#### Ref: documentation.wazuh.com/current/user-manual/capabilities/malware-detection/fim-yara.html

#### wazuh-dashboard
<img width="1873" height="1008" alt="image" src="https://github.com/user-attachments/assets/b097579c-e0fc-4f42-8f7f-cea7fe5550dd" />
