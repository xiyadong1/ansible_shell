#!/bin/bash
set -e

# ==============================
# 配置区
# ==============================
ANSIBLE_DIR="/home/ansible/ansible"
REPORT_DIR="$ANSIBLE_DIR/report"
REPORT_FILE="$REPORT_DIR/report.txt"

# 邮件配置
RECIPIENT="1539513407@qq.com"
SMTP_USER="1539513407@qq.com"        # 发件邮箱
SMTP_PASS="snbyfvzxaztebagi"  # QQ邮箱授权码
SMTP_SERVER="smtp.qq.com"
SMTP_PORT="587"

# msmtp 配置文件放在 root 目录下，避免权限问题
MSMTP_CONF="/root/.msmtprc"
MSMTP_LOG="$ANSIBLE_DIR/msmtp.log"
# ==============================

echo "🚀 开始系统巡检..."

# 创建报告目录
mkdir -p "$REPORT_DIR"

# 清理旧报告
if [[ -f "$REPORT_FILE" ]]; then
    rm -f "$REPORT_FILE"
    echo "🗑️ 旧报告已清理"
fi

cd "$ANSIBLE_DIR"

# 执行 Ansible 巡检
ansible-playbook -i hosts.ini playbooks/audit.yml
echo "✅ 巡检完成，报告生成在 $REPORT_FILE"

# ==============================
# 安装 msmtp（如果未安装）
# ==============================
if ! command -v msmtp >/dev/null 2>&1; then
    echo "⚙️ 安装 msmtp..."
    if command -v apt >/dev/null 2>&1; then
        apt update -y >/dev/null 2>&1
        apt install -y msmtp >/dev/null 2>&1
    elif command -v yum >/dev/null 2>&1; then
        yum install -y msmtp >/dev/null 2>&1
    elif command -v dnf >/dev/null 2>&1; then
        dnf install -y msmtp >/dev/null 2>&1
    else
        echo "❌ 未检测到支持的包管理器，请手动安装 msmtp"
        exit 1
    fi
fi

# ==============================
# 生成 msmtp 配置（覆盖旧配置）
# ==============================
cat > "$MSMTP_CONF" <<EOF
defaults
auth           on
tls            on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        $MSMTP_LOG

account        qq
host           $SMTP_SERVER
port           $SMTP_PORT
from           $SMTP_USER
user           $SMTP_USER
password       $SMTP_PASS

account default : qq
EOF

# ⚠️ 自动设置权限，避免 Permission denied
chown root:root "$MSMTP_CONF"
chmod 600 "$MSMTP_CONF"

# ==============================
# 发送邮件
# ==============================
if [[ -f "$REPORT_FILE" ]]; then
    echo "📧 正在发送邮件到 $RECIPIENT..."
    (
        echo "To: $RECIPIENT"
        echo "Subject: 系统巡检报告 - $(date '+%Y-%m-%d %H:%M:%S')"
        echo
        cat "$REPORT_FILE"
    ) | msmtp --file="$MSMTP_CONF" --account=qq "$RECIPIENT"

    if [[ $? -eq 0 ]]; then
        echo "✅ 邮件已发送"
    else
        echo "❌ 邮件发送失败，请检查 msmtp 配置或网络"
    fi
else
    echo "⚠️ 报告文件不存在，邮件未发送"
fi

