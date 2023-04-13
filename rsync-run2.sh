#!/bin/sh


#------------------------------------------------------------------
# Settings, customize this
#------------------------------------------------------------------

BACKUP="x.x.x.x:/usr/local/etc"  
BACKUPDIR="/"
KEEPDAYS=1
RSYNC="/usr/local/bin/rsync"
EXCLUDES="*.core"  
#------------------------------------------------------------------
DATE="`date +%Y-%m-%d`"		

#------------------------------------------------------------------
# Functions
#------------------------------------------------------------------

# create nonexistant directories, ensure permissions are correct
check_dir() {
	if [ ! -e "$1" ]; then
		mkdir "$1"
	fi
#	chmod 0700 "$1"
}

# synchronize two directories
sync_dir() {
	REXCLUDES=""
	for exc in ${3}; do
		REXCLUDES="--exclude ${exc} ${REXCLUDES}"
	done

## I'm using uncommon ssh port here 12533, change it to your needs
	${RSYNC} \
		--rsh="ssh -2 -l root -p 12533" \
		--group \
		--hard-links \
		--ignore-errors \
		--links \
		--owner \
		--partial \
		--perms \
		--recursive \
		--relative \
		--times \
		$REXCLUDES "${1}" "${2}"
}

# make the actual backup
sync() {
	echo "Syncing ..."

	TARGETDIR="${BACKUPDIR}/"

	check_dir "${BACKUPDIR}"
	check_dir "${TARGETDIR}"

	for b in ${BACKUP}; do
		sync_dir "${b}" "${TARGETDIR}" "${EXCLUDES}"
	done
}

# delete old backup directories
#rm_obsolete_dirs() {
#	find -L ${BACKUPDIR} \
#	-maxdepth 1 \
#	-name "${DIRPREFIX}*" \
#	-mtime +"${KEEPDAYS}" \
#	-exec rm -fr {} \;
#}

# show how much diskspace is used by the backups
report_diskspace() {
	echo
	echo "-------------------------------------------------------"
	echo "disk space:"

	cd ${BACKUPDIR}
	for dir in `ls -r`; do
		echo -n "${dir}:"
		du -hs "${BACKUPDIR}/${dir}"
	done
	echo
	echo -n "total:"
	du -hs "${BACKUPDIR}"
	echo
	df -h "${BACKUPDIR}" |tail -n 1
}

#------------------------------------------------------------------
# Run
#------------------------------------------------------------------
sync  
#rm_obsolete_dirs && \
#report_diskspace



