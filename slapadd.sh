#!/bin/sh

slapadd -n 0 -F /etc/openldap/slapd.d  <<EOF
#
# See slapd-config(5) for details on configuration options.
# This file should NOT be world readable.
#
dn: cn=config
objectClass: olcGlobal
cn: config
#
#
# Define global ACLs to disable default read access.
#
# If you change this, set pidfile variable in /etc/conf.d/slapd!
olcPidFile: /run/openldap/slapd.pid
olcArgsFile: /run/openldap/slapd.args
#
# Do not enable referrals until AFTER you have a working directory
# service AND an understanding of referrals.
#olcReferral:	ldap://root.openldap.org
#
# Sample security restrictions
#	Require integrity protection (prevent hijacking)
#	Require 112-bit (3DES or better) encryption for updates
#	Require 64-bit encryption for simple bind
#olcSecurity: ssf=1 update_ssf=112 simple_bind=64
#
olcTLSCACertificateFile: $LDAP_TLS_CACERT
olcTLSCertificateFile: $LDAP_TLS_CERT
olcTLSCertificateKeyFile: $LDAP_TLS_KEY
olcTLSVerifyClient: $LDAP_TLS_VERIFY

#
# Make on-line configuration (OLC) accessible via ldap:///:
#
dn: olcDatabase=config,cn=config
objectClass: olcDatabaseConfig
olcRootDN: cn=admin,cn=config
olcRootPW: $(slappasswd -s $LDAP_CONFIGPASS)

#
# Load dynamic backend modules:
#
dn: cn=module,cn=config
objectClass: olcModuleList
cn: module
olcModulepath:	/usr/lib/openldap
#olcModuleload:	back_bdb.so
#olcModuleload:	back_hdb.so
#olcModuleload:	back_ldap.so
olcModuleload:	back_mdb.so
#olcModuleload:	back_passwd.so
#olcModuleload:	back_shell.so
olcModuleload:	syncprov.so

dn: cn=schema,cn=config
objectClass: olcSchemaConfig
cn: schema

include: file:///etc/openldap/schema/core.ldif
include: file:///etc/openldap/schema/cosine.ldif
include: file:///etc/openldap/schema/inetorgperson.ldif

# Frontend settings
#
#dn: olcDatabase=frontend,cn=config
#objectClass: olcDatabaseConfig
#objectClass: olcFrontendConfig
#olcDatabase: frontend
#
# Sample global access control policy:
#	Root DSE: allow anyone to read it
#	Subschema (sub)entry DSE: allow anyone to read it
#	Other DSEs:
#		Allow self write access
#		Allow authenticated users read access
#		Allow anonymous users to authenticate
#
#olcAccess: to dn.base="" by * read
#olcAccess: to dn.base="cn=Subschema" by * read
#olcAccess: to *
#	by self write
#	by users read
#	by anonymous auth
#
# if no access controls are present, the default policy
# allows anyone and everyone to read anything but restricts
# updates to rootdn.  (e.g., "access to * by * read")
#
# rootdn can always read and write EVERYTHING!
#


#######################################################################
# LMDB database definitions
#######################################################################
#
dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: mdb
olcAccess: to * by dn.exact=gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth manage by * break
olcSuffix: ${LDAP_BASE_DN}
olcRootDN: cn=admin,${LDAP_BASE_DN}
#
# Cleartext passwords, especially for the rootdn, should
# be avoided.  See slappasswd(8) and slapd-config(5) for details.
# Use of strong authentication encouraged.
olcRootPW: $(slappasswd -s $LDAP_ROOTPASS)
#
# The database directory MUST exist prior to running slapd AND
# should only be accessible by the slapd and slap tools.
# Mode 700 recommended.
olcDbDirectory:	/var/lib/openldap/openldap-data
#
# Indices to maintain
olcDbIndex: objectClass eq
EOF
