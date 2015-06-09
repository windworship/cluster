#!/bin/bash
# 
# Author: jimin.huang
# 
# Created Time: 2015年06月05日 星期五 18时44分36秒
# 

ROOT_PATH='/usr/local/'
INSTALL=('node-action' 'ip-change')
ACTION_BASH="${ROOT_PATH}${INSTALL[1]}/register.sh"
RELOAD_FILE="${ROOT_PATH}${INSTALL[0]}/reload.txt"

if [[ $USER != "root" ]];then
    echo "无root权限！"
    exit
fi

Install_node-action(){
    cp node-action.sh testNodeAction.sh IpChangeLinkNodeAction.sh docker-compose.model relative.txt $1
}

Install_ip-change(){
    cp ip-change.sh testIpChange.sh $1
}

for installation in ${INSTALL[@]}
do
    echo "开始安装$installation";
    if [ -d "${ROOT_PATH}${installation}" ];then
        rm -Rf ${ROOT_PATH}${installation}
    fi

    mkdir ${ROOT_PATH}${installation}

    "Install_${installation}" ${ROOT_PATH}${installation}
    

    if [ -L /bin/${installation} ];then
        rm -Rf /bin/${installation}
    fi

    echo "创建符号链接"
    ln -s ${ROOT_PATH}${installation}/${installation}.sh /bin/${installation}

    echo "测试安装"
    ${installation} test
    if [ ! $? -eq 0 ];then
        echo "${installation安装失败}"
        exit $?
    fi

    echo "${installation}安装完毕,可以如下使用"
    ${installation}
done


if [ -L /bin/ICLNA ];then
    rm -Rf /bin/ICLNA
fi

ln -s ${ROOT_PATH}${INSTALL[0]}/IpChangeLinkNodeAction.sh /bin/ICLNA

if [ ! -d /etc/cron.minutely ];then
    mkdir /etc/cron.minutely
fi

minuteCron=`cat /etc/crontab | \
    awk '/\* \* \* \* \* root run-parts \/etc\/cron.minutely/{print $1}'`

if [[ -z $minuteCron ]];then
    echo '* * * * * root run-parts /etc/cron.minutely' >> /etc/crontab
fi

echo -e "#!/bin/bash\nsudo ip-change start > /dev/console" > /etc/cron.minutely/ipChangeTimer
