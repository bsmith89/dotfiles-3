BACKUP_DIR=${PWD}/backups
SRC_DIR=home
HOME_DIR=${HOME}
PLATFORM_DIR=platform/${PLATFORM}

install: update-submodules
	rsync -vab --backup-dir ${BACKUP_DIR} ${SRC_DIR}/ ${HOME_DIR}/
	if [[ -n $$PLATFORM ]] ; then \
		rsync -vab --backup-dir ${BACKUP_DIR} ${PLATFORM_DIR}/ ${HOME_DIR}/ ; \
	fi

update-submodules: 
	# I suppose that this must update all submodules
	git submodule update --init --recursive
	git submodule foreach --recursive git pull origin master

restore:
	# Return backed-up files to their original place
	rsync -va ${BACKUP_DIR}/ ${HOME_DIR}/
	rm -r ${BACKUP_DIR}

import:
	for path in `find ${SRC_DIR} -depth 1` ; do \
		import_from=${HOME_DIR}/`basename $$path` ; \
		if [[ -e $$import_from ]] ; then \
			rsync -va $$import_from ${SRC_DIR}/ ; \
		fi ; \
	done
	if [[ -n $$PLATFORM ]]; then \
		for path in `find ${PLATFORM_DIR} -depth 1` ; do \
			import_from=${HOME_DIR}/`basename $$path` ; \
			if [[ -e import_from ]] ; then \
				rsync -va $$import_from ${SRC_DIR}/ ; \
			fi ; \
		done ; \
	fi
