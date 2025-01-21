# README.md

## Описание

Этот проект включает Ansible плейбуки и роли для настройки сервера раздачи статики через Nginx в тестовом окружении на основе Docker. Настройка сервера охватывает:
1. Создание и управление пользователями и группами.
2. Настройку SSH-сервера.
3. Установку Zsh/Oh My Zsh для указанных пользователей.
4. Обновление системы и установку утилит.
5. Настройку и развертывание Nginx для раздачи статики.
6. Размещение статики по пути `/images`.

---

## Структура проекта

```
.
├── Dockerfile
├── docker-compose.yml
├── inventory
│   ├── group_vars
│   │   └── all
│   │       └── vault.yml
│   └── hosts.yml
├── playbook.yml
├── roles
│   ├── deploy_static
│   ├── nginx_setup
│   ├── ssh_config
│   ├── system_update
│   ├── user_management
│   │   └── vars
│   │       └── main.yml
│   └── zsh_setup
├── id_rsa.pub
└── secrets
    └── bob_ssh_key.pub
```

---

## Предварительная настройка

1. **Добавьте SSH-ключ для пользователя Ansible:**
   Поместите публичный ключ в файл `id_rsa.pub` в корень репозитория, рядом с `Dockerfile`.

2. **Определите переменные для управления пользователями:**
   В файле `roles/user_management/vars/main.yml` укажите группы и пользователей:

   ```yaml
   custom_groups:
     - name: developers
     - name: admins

   users:
     - name: "felix"
       shell: "/bin/zsh"
       state: "present"
       groups: ["developers", "sudo"]
       password: "felix_password"
       ssh_key_path: /secrets/bob_ssh_key.pub

     - name: "habib"
       state: "absent"

     - name: "hannah"
       state: "absent"

     - name: "nikita"
       shell: "/bin/sh"
       state: "present"
       groups: ["developers"]
       password: "nikita_password"
       ssh_key_path: /secrets/nikita_ssh_key.pub
   ```

3. **Сохраните пароли в зашифрованном файле:**
   В файле `inventory/group_vars/all/vault.yml` храните пароли в формате:

   ```yaml
   bob_password: "YourBobPassword123"
   felix_password: "TupacShakur5"
   nikita_password: "AnotherSecurePassword"
   ```

   **Команды для работы с Ansible Vault:**
   - **Создать зашифрованный файл:**
     ```bash
     ansible-vault create inventory/group_vars/all/vault.yml
     ```
   - **Редактировать зашифрованный файл:**
     ```bash
     ansible-vault edit inventory/group_vars/all/vault.yml
     ```
   - **Просмотреть содержимое файла:**
     ```bash
     ansible-vault view inventory/group_vars/all/vault.yml
     ```
   - **Зашифровать существующий файл:**
     ```bash
     ansible-vault encrypt inventory/group_vars/all/vault.yml
     ```
   - **Расшифровать файл:**
     ```bash
     ansible-vault decrypt inventory/group_vars/all/vault.yml
     ```

4. **Настройте файл `inventory/hosts.yml`:**
   Укажите параметры для подключения к серверу:

   ```yaml
   all:
     hosts:
       docker_host:
         ansible_host: 127.0.0.1
         ansible_port: 2222
         ansible_user: ubuntu
         ansible_ssh_private_key_file: ./path_to_your_private_ssh_key
   ```

5. **Создайте папку `secrets`:**
   В ней разместите публичные ключи пользователей, например `bob_ssh_key.pub`.

---

## Запуск проекта

1. **Разверните тестовое окружение:**
   ```bash
   docker-compose up -d
   ```

2. **Запустите плейбук:**
   
Перед запуском плейбука убедитесь, что библиотека `passlib` установлена. Если она не установлена, выполните следующую команду:
    ```bash
    pip install passlib
    ```
После установки библиотеки можно запустить плейбук:
   ```bash
   ansible-playbook -i inventory/hosts.yml playbook.yml --ask-vault-pass
   ```

4. **Проверьте результаты:**
   - На порту `80` по пути `/images` должна отображаться структура файлов.
   - Файлы статики доступны по пути `/images/<filename>`.
   - Подключение по SSH доступно на порту `2222`.

---

## Проверка работы

1. **Проверьте Nginx:**
   Откройте в браузере `http://<ваш-сервер>:80/images`.

2. **Подключитесь по SSH:**
   ```bash
   ssh -i id_rsa -p 2222 ubuntu@127.0.0.1
   ```

3. **Проверьте созданных пользователей:**
   ```bash
   getent passwd
   ```

4. **Убедитесь в корректной настройке Nginx:**
   ```bash
   sudo nginx -t
   ```

5. **Проверьте установленные пакеты:**
   ```bash
   dpkg -l | grep -E "htop|ncdu|git|nano"
   ```

