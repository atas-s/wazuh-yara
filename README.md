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
Bu playbook sadece guncel yara kurallari yayinlandiginda sunuculara dagitim yapacak. Boylece gereksiz yere tum sunucularin kural guncellemek icin trafik yapmasina gerek olmayacak.

  - pip3 install valhallaAPI
  - playbook eklenecek!

#### Ref: documentation.wazuh.com/current/user-manual/capabilities/malware-detection/fim-yara.html

#### wazuh-dashboard
<img width="1873" height="1008" alt="image" src="https://github.com/user-attachments/assets/b097579c-e0fc-4f42-8f7f-cea7fe5550dd" />
