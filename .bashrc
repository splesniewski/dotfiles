#
umask 077
unset MAILCHECK
unset MAILPATH

shcat() { while test $# -ge 1 ; do while read i ; do echo "${i}"; done < $1 ; shift; done ; }
rnd () { echo ${RANDOM} | awk "{printf (\"%d\", (\$1/32767)*$1);}"; }

export HOST=`uname -n | awk -F"." '{print $1}' | tr A-Z a-z` 
export OS=`uname -s`
export OSREL=`uname -r`
export PROCTYPE=`uname -p`
export RSYNC_RSH=ssh
export DATESTAMP=`TZ=UTC date +%Y%m%d%_H%M%SZ`
export RUBSTAMP=${OS}_${OSREL}_${PROCTYPE}
export GZIP="-9"
export LC_COLLATE=C

EUSER=`id | sed  's/.*uid=[0-9]\{1,\}(\([a-zA-Z0-9_]\{1,\}\)).*/\1/'`
if [ "${EUSER}" = "" ]; then EUSER=unknown; fi; export EUSER

EGROUP=`id | sed 's/.*gid=\([^ ]*\).*/\1/; s/.*(\(.*\))/\1/'`
if [ "{$EGROUP}" = "" ]; then EGROUP="[unknown]"; fi; export EGROUP

# setup PATH and MANPATH
PATH=${HOME}/.root/${RUBSTAMP}/opt/local/bin:${HOME}/.root/${RUBSTAMP}/usr/bin:${PATH}
PATH=${HOME}/.root/opt/local/bin:${HOME}/.root/usr/bin:${PATH}
PATH=${PATH}:/opt/local/bin
PATH=${PATH}:/usr/bin:/sbin:/usr/sbin:/bin
export PATH
MANPATH=/usr/man

if [ -d ${HOME}/.env ]; then
    pushd ${HOME}/.env > /dev/null
    for ev in *; do
	if [ -f ${ev} ]; then
	    for p in `egrep -v '^#|^ *$' ${ev}`; do
		if [ -e ${p} ]; then
		    eval ${ev}=\$$ev:\$p
		fi
	    done
	fi
    done
    popd > /dev/null
fi
export ORIGPATH=${PATH}

WORKINGDIR=/var/tmp
if [ ! -d ${WORKINGDIR}/${USER} ]; then mkdir ${WORKINGDIR}/${USER}; fi

if [ -z "${level}" ]; then export level=0; fi 
# setup for interactive (if this is one)
if [ -n "$PS1" ]; then
    export level="`expr ${level} + 1`"

    ignoeeof=22
    export EDITOR=emacs 
    export PAGER=less
    shopt -s checkwinsize

    PS1_SHELL="b"
    if [ ${BASH_VERSINFO[0]} -gt 2 ] && 
	[ -f ${HOME}/.bash_completion ]; then 
	. ${HOME}/.bash_completion
	PS1_SHELL="B"
    fi

    # test for potentially unknown term types and set TERM to something sane
    if [ "$TERM" = "screen" -o "$TERM" = "xterm-color" ]; then
	if [ -x /usr/bin/infocmp ]; then
	    (/usr/bin/infocmp 2>&1) 1>/dev/null;rc=$?
	    if [ $rc -ne 0 ]; then
		export TERM=vt100
	    fi
	fi
    fi
    # get random name for shell
    t=`rnd \`wc -l ${HOME}/.alphabets\` `; export ALNUM=`expr $t + 1` ; unset t
    export ALPHABET=`head -${ALNUM} ${HOME}/.alphabets | tail -1`
    LETTER=`expr \`rnd 26\` + 2`;
    export PS1_SHELLNAME=`echo ${ALPHABET} | tr ' :' '\\n\\n'| head -${LETTER}  | tail -1`

    # does this have acces to ssh-agent?
    PS1_SSHAGENT="-"; if [ -n "${SSH_AUTH_SOCK}" ]; then PS1_SSHAGENT="+"; fi

    # is this shell inside a screen session
    PS1_SCREENL="("; PS1_SCREENR=")"
    if [ -n "${STY}" ] ; then PS1_SCREENL="[";  PS1_SCREENR="]"; fi

    # PS1 OS indicator
    PS1_OS=`echo ${OS} | awk '{print substr($1,0,2)}'`
    if [ "${OS}" = "SunOS" ]; then PS1_OS=${PS1_OS}`echo ${OSREL} | nawk -F. '{printf("%X",$2)}'`; fi

    PS1='${PS1_SCREENL}${PS1_SCRIPTFLAG}${level}${PS1_SHELL}${PS1_OS}${PS1_SSHAGENT}${PS1_SHELLNAME}:${EGROUP}${PS1_SCREENR}\u@\h:\w \$ '
	
    # setup history
    HISTDIR=${HOME}/.history/${EUSER}/${HOST}

    # if home directory is not writable by root(NFS mount) it's
    # symlinked by-hand into ${WORKINGDIR}.  Make sure the directory
    # is there. (ln -s ${WORKINGDIR}/.history/root ${HOME}/.history/root)
    if [ -L ${HOME}/.history/${EUSER} ]; then
	pushd ${HOME}/.history  > /dev/null
	# determine the desination of symlink 
	syml=`ls -l  $EUSER | sed -e "s/.*-> //"`
	mkdir -p ${syml}
	popd > /dev/null
	unset syml
    fi

    if [ ! -d ${HISTDIR} ]; then mkdir -p ${HISTDIR}; fi
    if [ ! -d ${HISTDIR}/script ]; then mkdir -p ${HISTDIR}/script; fi

    export HISTSIZE=1024
    HISTFILE=${HISTDIR}/`TZ=UTC date +%Y%m%d%H%M%SZ`.b

    if [ -e ${HISTDIR}/latest ]; then
	cp ${HISTDIR}/latest ${HISTFILE}
	rm -f ${HISTDIR}/latest
    fi
    ln -s ${HISTFILE} ${HISTDIR}/latest

    if [ -f ${HOME}/.bash_alias   ]; then source ${HOME}/.bash_alias; fi
fi # interactive shell

# source any local setup
if [ -f ${HOME}/.bashrc.local ]; then source ${HOME}/.bashrc.local; fi
if [ -f ${HOME}/.bashrc.${HOST} ]; then source ${HOME}/.bashrc.${HOST}; fi
