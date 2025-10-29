1️⃣ 控制节点准备老套路：切到 root更新系统安装 Ansible生成 SSH 密钥分发密钥到被控主机核心：控制节点与被控主机免密打通。如果这一步没搞好，后续操作都无法执行。💡 Tip：可以用 for in 循环批量分发密钥到各主机。

![图片](http://pic.opsdev.top/pic/640)
![图片](http://pic.opsdev.top/pic/640)

 for in 循环分发密钥到控制主机
 
![图片](http://pic.opsdev.top/pic/640)

2️⃣ 主机环境设置用户名：ansible（演示用，生产环境请使用正规用户名，哈哈）环境目录：/home/ansible/在 ansible 文件目录下新建 hosts.ini，写明所有要巡检的服务器 IP。巡检 Playbook：audit.yml，放在 playbooks/ 目录下。

![图片](http://pic.opsdev.top/pic/640)

在ansible文件目录下新建hosts.ini写清楚所有要巡检的服务器 IP

![图片](http://pic.opsdev.top/pic/640)

巡检 Playbook：audit.yml，放在 playbooks/ 目录下。

![图片](http://pic.opsdev.top/pic/640)

3️⃣ Playbook（audit.yml）特点：收集 CPU、内存、磁盘、温度 等常用指标目标机缺少命令会自动安装，安装失败或不支持则跳过保证流程不中断，即使单台机器报错也不影响整体执行⚡ Tip：逻辑写死，演示效果直观，入门阶段优先跑通结果，生产环境可增加容错和兼容性。

![图片](http://pic.opsdev.top/pic/640)

网盘或者GitHub链接在文章末尾；整个ansible文件夹都在里面；
4️⃣ 一键执行脚本脚本：audit_full.sh功能：调用 audit.yml，结果保存到 report/，并自动发送邮件提醒结果：report/ 下生成每台主机巡检结果，同时收到巡检完成邮件💡 Tip：如果系统没安装邮件服务，脚本会自动补装。

![图片](http://pic.opsdev.top/pic/640)
![图片](http://pic.opsdev.top/pic/640)
![图片](http://pic.opsdev.top/pic/640)

跑完以后，report/ 目录下会出现每台主机的巡检结果，同时会收到一封巡检完成的提醒邮件。这是目前成型的文件结构；执行成功后随即收到邮件提醒

![图片](http://pic.opsdev.top/pic/640)

5️⃣ 定时执行使用 crontab -e 设置定时任务，实现自动周期巡检。

![图片](http://pic.opsdev.top/pic/640)

6️⃣ 踩坑总结权限问题：免密没配好，Ansible 报错 Permission denied命令缺失：新系统可能没装 sensors，需要 apt-get install lm-sensors版本差异：不同系统命令输出格式不一致，解析时可能踩坑流程不中断：Playbook 中 ignore_errors: yes，保证哪怕一台机器不支持，也不影响整体执行核心目标：即使部分机器报错，整体流程仍然可执行。

7️⃣ K8s 与 Ansible 的分工Kubernetes：管理容器应用，负责 Pod 调度、Service 暴露、Deployment 滚动升级Ansible：管理宿主机，进行内核参数调优、硬件巡检、系统依赖安装、节点初始化Helm/Operator/ArgoCD：在集群内执行声明式、持续交付类比理解：Helm 的 chart ≈ Ansible 的 role（模板化、可复用配置）Operator 自动化 ≈ Playbook（都是自动化，但 Operator 持续运行在容器里，Playbook 多在宿主机外一次性执行）总结：掌握 Ansible，可以打通宿主机到容器的整个技术栈，从基础环境到云原生应用，整个流程都能掌控。
