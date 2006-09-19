# AST_GCC_ATTRIBUTE([attribute name])

AC_DEFUN([AST_GCC_ATTRIBUTE],
[
AC_MSG_CHECKING(for compiler 'attribute $1' support)
AC_COMPILE_IFELSE(
	AC_LANG_PROGRAM([static int __attribute__(($1)) test(void) {}],
			[]),
	AC_MSG_RESULT(yes)
	AC_DEFINE_UNQUOTED([HAVE_ATTRIBUTE_$1], 1, [Define to 1 if your GCC C compiler supports the '$1' attribute.]),
	AC_MSG_RESULT(no))
])

# AST_EXT_LIB_SETUP([package symbol name], [package friendly name], [package option name], [additional help text])

AC_DEFUN([AST_EXT_LIB_SETUP],
[
$1_DESCRIP="$2"
$1_OPTION="$3"
AC_ARG_WITH([$3], AC_HELP_STRING([--with-$3=PATH],[use $2 files in PATH $4]),[
case ${withval} in
     n|no)
     USE_$1=no
     ;;
     y|ye|yes)
     $1_MANDATORY="yes"
     ;;
     *)
     $1_DIR="${withval}"
     $1_MANDATORY="yes"
     ;;
esac
])
PBX_$1=0
AC_SUBST([$1_LIB])
AC_SUBST([$1_INCLUDE])
AC_SUBST([PBX_$1])
])

# AST_EXT_LIB_CHECK([package symbol name], [package library name], [function to check], [package header], [additional LIB data])

AC_DEFUN([AST_EXT_LIB_CHECK],
[
if test "${USE_$1}" != "no"; then
   pbxlibdir=""
   if test "x${$1_DIR}" != "x"; then
      if test -d ${$1_DIR}/lib; then
      	 pbxlibdir="-L${$1_DIR}/lib"
      else
      	 pbxlibdir="-L${$1_DIR}"
      fi
   fi
   AC_CHECK_LIB([$2], [$3], [AST_$1_FOUND=yes], [AST_$1_FOUND=no], ${pbxlibdir} $5)

   if test "${AST_$1_FOUND}" = "yes"; then
      $1_LIB="-l$2 $5"
      $1_HEADER_FOUND="1"
      if test "x${$1_DIR}" != "x"; then
         $1_LIB="${pbxlibdir} ${$1_LIB}"
	 $1_INCLUDE="-I${$1_DIR}/include"
	 if test "x$4" != "x" ; then
	    AC_CHECK_HEADER([${$1_DIR}/include/$4], [$1_HEADER_FOUND=1], [$1_HEADER_FOUND=0] )
	 fi
      else
	 if test "x$4" != "x" ; then
            AC_CHECK_HEADER([$4], [$1_HEADER_FOUND=1], [$1_HEADER_FOUND=0] )
	 fi
      fi
      if test "x${$1_HEADER_FOUND}" = "x0" ; then
         if test ! -z "${$1_MANDATORY}" ;
         then
            AC_MSG_NOTICE( ***)
            AC_MSG_NOTICE( *** It appears that you do not have the $2 development package installed.)
            AC_MSG_NOTICE( *** Please install it to include ${$1_DESCRIP} support, or re-run configure)
            AC_MSG_NOTICE( *** without explicitly specifying --with-${$1_OPTION})
            exit 1
         fi
         $1_LIB=""
         $1_INCLUDE=""
         PBX_$1=0
      else
         PBX_$1=1
         AC_DEFINE_UNQUOTED([HAVE_$1], 1, [Define to indicate the ${$1_DESCRIP} library])
      fi
   elif test ! -z "${$1_MANDATORY}";
   then
      AC_MSG_NOTICE(***)
      AC_MSG_NOTICE(*** The ${$1_DESCRIP} installation on this system appears to be broken.)
      AC_MSG_NOTICE(*** Either correct the installation, or run configure)
      AC_MSG_NOTICE(*** without explicitly specifying --with-${$1_OPTION})
      exit 1
   fi
fi
])


AC_DEFUN(
[AST_CHECK_GNU_MAKE], [AC_CACHE_CHECK(for GNU make, GNU_MAKE,
   GNU_MAKE='Not Found' ;
   GNU_MAKE_VERSION_MAJOR=0 ;
   GNU_MAKE_VERSION_MINOR=0 ;
   for a in make gmake gnumake ; do
      if test -z "$a" ; then continue ; fi ;
      if ( sh -c "$a --version" 2> /dev/null | grep GNU  2>&1 > /dev/null ) ;  then
         GNU_MAKE=$a ;
         GNU_MAKE_VERSION_MAJOR=`$GNU_MAKE --version | grep "GNU Make" | cut -f3 -d' ' | cut -f1 -d'.'`
         GNU_MAKE_VERSION_MINOR=`$GNU_MAKE --version | grep "GNU Make" | cut -f2 -d'.' | cut -c1-2`
         break;
      fi
   done ;
) ;
if test  "x$GNU_MAKE" = "xNot Found"  ; then
   AC_MSG_ERROR( *** Please install GNU make.  It is required to build Asterisk!)
   exit 1
fi
AC_SUBST([GNU_MAKE])
])


AC_DEFUN(
[AST_CHECK_PWLIB], [
PWLIB_INCDIR=
PWLIB_LIBDIR=
if test "${PWLIBDIR:-unset}" != "unset" ; then
  AC_CHECK_FILE(${PWLIBDIR}/version.h, HAS_PWLIB=1, )
fi
if test "${HAS_PWLIB:-unset}" = "unset" ; then
  if test "${OPENH323DIR:-unset}" != "unset"; then
    AC_CHECK_FILE(${OPENH323DIR}/../pwlib/version.h, HAS_PWLIB=1, )
  fi
  if test "${HAS_PWLIB:-unset}" != "unset" ; then
    PWLIBDIR="${OPENH323DIR}/../pwlib"
  else
    AC_CHECK_FILE(${HOME}/pwlib/include/ptlib.h, HAS_PWLIB=1, )
    if test "${HAS_PWLIB:-unset}" != "unset" ; then
      PWLIBDIR="${HOME}/pwlib"
    else
      AC_CHECK_FILE(/usr/local/include/ptlib.h, HAS_PWLIB=1, )
      if test "${HAS_PWLIB:-unset}" != "unset" ; then
        AC_PATH_PROG(PTLIB_CONFIG, ptlib-config, , /usr/local/bin)
        if test "${PTLIB_CONFIG:-unset}" = "unset" ; then
          AC_PATH_PROG(PTLIB_CONFIG, ptlib-config, , /usr/local/share/pwlib/make)
        fi
        PWLIB_INCDIR="/usr/local/include"
        PWLIB_LIBDIR="/usr/local/lib"
      else
        AC_CHECK_FILE(/usr/include/ptlib.h, HAS_PWLIB=1, )
        if test "${HAS_PWLIB:-unset}" != "unset" ; then
          AC_PATH_PROG(PTLIB_CONFIG, ptlib-config, , /usr/share/pwlib/make)
          PWLIB_INCDIR="/usr/include"
          PWLIB_LIBDIR="/usr/lib"
        fi
      fi
    fi
  fi
fi

#if test "${HAS_PWLIB:-unset}" = "unset" ; then
#  echo "Cannot find pwlib - please install or set PWLIBDIR and try again"
#  exit
#fi

if test "${HAS_PWLIB:-unset}" != "unset" ; then
  if test "${PWLIBDIR:-unset}" = "unset" ; then
    if test "${PTLIB_CONFIG:-unset}" != "unset" ; then
      PWLIBDIR=`$PTLIB_CONFIG --prefix`
    else
      echo "Cannot find ptlib-config - please install and try again"
      exit
    fi
  fi

  if test "x$PWLIBDIR" = "x/usr" -o "x$PWLIBDIR" = "x/usr/"; then
    PWLIBDIR="/usr/share/pwlib"
    PWLIB_INCDIR="/usr/include"
    PWLIB_LIBDIR="/usr/lib"
  fi
  if test "x$PWLIBDIR" = "x/usr/local" -o "x$PWLIBDIR" = "x/usr/"; then
    PWLIBDIR="/usr/local/share/pwlib"
    PWLIB_INCDIR="/usr/local/include"
    PWLIB_LIBDIR="/usr/local/lib"
  fi

  if test "${PWLIB_INCDIR:-unset}" = "unset"; then
    PWLIB_INCDIR="${PWLIBDIR}/include"
  fi
  if test "${PWLIB_LIBDIR:-unset}" = "unset"; then
    PWLIB_LIBDIR="${PWLIBDIR}/lib"
  fi

  AC_SUBST([PWLIBDIR])
  AC_SUBST([PWLIB_INCDIR])
  AC_SUBST([PWLIB_LIBDIR])
fi
])


AC_DEFUN(
[AST_CHECK_OPENH323_PLATFORM], [
PWLIB_OSTYPE=
case "$host_os" in
  linux*)          PWLIB_OSTYPE=linux ;
  		;;
  freebsd* )       PWLIB_OSTYPE=FreeBSD ;
  		;;
  openbsd* )       PWLIB_OSTYPE=OpenBSD ;
				   ENDLDLIBS="-lossaudio" ;
		;;
  netbsd* )        PWLIB_OSTYPE=NetBSD ;
				   ENDLDLIBS="-lossaudio" ;
		;;
  solaris* | sunos* ) PWLIB_OSTYPE=solaris ;
		;;
  darwin* )	       PWLIB_OSTYPE=Darwin ;
		;;
  beos*)           PWLIB_OSTYPE=beos ;
                   STDCCFLAGS="$STDCCFLAGS -D__BEOS__"
		;;
  cygwin*)         PWLIB_OSTYPE=cygwin ;
		;;
  mingw*)	       PWLIB_OSTYPE=mingw ;
		           STDCCFLAGS="$STDCCFLAGS -mms-bitfields" ;
		           ENDLDLIBS="-lwinmm -lwsock32 -lsnmpapi -lmpr -lcomdlg32 -lgdi32 -lavicap32" ;
		;;
  * )		       PWLIB_OSTYPE="$host_os" ;
		           AC_MSG_WARN("OS $PWLIB_OSTYPE not recognized - proceed with caution!") ;
		;;
esac

PWLIB_MACHTYPE=
case "$host_cpu" in
   x86 | i686 | i586 | i486 | i386 ) PWLIB_MACHTYPE=x86
                   ;;

   x86_64)	   PWLIB_MACHTYPE=x86_64 ;
		   P_64BIT=1 ;
                   LIB64=1 ;
		   ;;

   alpha | alphaev56 | alphaev6 | alphaev67 | alphaev7) PWLIB_MACHTYPE=alpha ;
		   P_64BIT=1 ;
		   ;;

   sparc )         PWLIB_MACHTYPE=sparc ;
		   ;;

   powerpc )       PWLIB_MACHTYPE=ppc ;
		   ;;

   ppc )           PWLIB_MACHTYPE=ppc ;
		   ;;

   powerpc64 )     PWLIB_MACHTYPE=ppc64 ;
		   P_64BIT=1 ;
                   LIB64=1 ;
		   ;;

   ppc64 )         PWLIB_MACHTYPE=ppc64 ;
		   P_64BIT=1 ;
                   LIB64=1 ;
		   ;;

   ia64)	   PWLIB_MACHTYPE=ia64 ;
		   P_64BIT=1 ;
	  	   ;;

   s390x)	   PWLIB_MACHTYPE=s390x ;
		   P_64BIT=1 ;
                   LIB64=1 ;
		   ;;

   s390)	   PWLIB_MACHTYPE=s390 ;
		   ;;

   * )		   PWLIB_MACHTYPE="$host_cpu";
		   AC_MSG_WARN("CPU $PWLIB_MACHTYPE not recognized - proceed with caution!") ;;
esac

PWLIB_PLATFORM="${PWLIB_OSTYPE}_${PWLIB_MACHTYPE}"

AC_SUBST([PWLIB_PLATFORM])
])


AC_DEFUN(
[AST_CHECK_OPENH323], [
OPENH323_INCDIR=
OPENH323_LIBDIR=
if test "${OPENH323DIR:-unset}" != "unset" ; then
  AC_CHECK_FILE(${OPENH323DIR}/version.h, HAS_OPENH323=1, )
fi
if test "${HAS_OPENH323:-unset}" = "unset" ; then
  AC_CHECK_FILE(${PWLIBDIR}/../openh323/version.h, OPENH323DIR="${PWLIBDIR}/../openh323"; HAS_OPENH323=1, )
  if test "${HAS_OPENH323:-unset}" != "unset" ; then
    OPENH323DIR="${PWLIBDIR}/../openh323"
    AC_CHECK_FILE(${OPENH323DIR}/include/h323.h, , OPENH323_INCDIR="${PWLIB_INCDIR}/openh323"; OPENH323_LIBDIR="${PWLIB_LIBDIR}")
  else
    AC_CHECK_FILE(${HOME}/openh323/include/h323.h, HAS_OPENH323=1, )
    if test "${HAS_OPENH323:-unset}" != "unset" ; then
      OPENH323DIR="${HOME}/openh323"
    else
      AC_CHECK_FILE(/usr/local/include/openh323/h323.h, HAS_OPENH323=1, )
      if test "${HAS_OPENH323:-unset}" != "unset" ; then
        OPENH323DIR="/usr/local/share/openh323"
        OPENH323_INCDIR="/usr/local/include/openh323"
        OPENH323_LIBDIR="/usr/local/lib"
      else
        AC_CHECK_FILE(/usr/include/openh323/h323.h, HAS_OPENH323=1, )
        if test "${HAS_OPENH323:-unset}" != "unset" ; then
          OPENH323DIR="/usr/share/openh323"
          OPENH323_INCDIR="/usr/include/openh323"
          OPENH323_LIBDIR="/usr/lib"
        fi
      fi
    fi
  fi
fi

if test "${HAS_OPENH323:-unset}" != "unset" ; then
  if test "${OPENH323_INCDIR:-unset}" = "unset"; then
    OPENH323_INCDIR="${OPENH323DIR}/include"
  fi
  if test "${OPENH323_LIBDIR:-unset}" = "unset"; then
    OPENH323_LIBDIR="${OPENH323DIR}/lib"
  fi

  AC_SUBST([OPENH323DIR])
  AC_SUBST([OPENH323_INCDIR])
  AC_SUBST([OPENH323_LIBDIR])
fi
])


AC_DEFUN(
[AST_CHECK_PWLIB_VERSION], [
	if test "${HAS_$2:-unset}" != "unset"; then
		$2_VERSION=`grep "$2_VERSION" ${$2_INCDIR}/$3 | cut -f2 -d ' ' | sed -e 's/"//g'`
		$2_MAJOR_VERSION=`echo ${$2_VERSION} | cut -f1 -d.`
		$2_MINOR_VERSION=`echo ${$2_VERSION} | cut -f2 -d.`
		$2_BUILD_NUMBER=`echo ${$2_VERSION} | cut -f3 -d.`
		let $2_VER=${$2_MAJOR_VERSION}*10000+${$2_MINOR_VERSION}*100+${$2_BUILD_NUMBER}
		let $2_REQ=$4*10000+$5*100+$6

		AC_MSG_CHECKING(if $1 version ${$2_VERSION} is compatible with chan_h323)
		if test ${$2_VER} -lt ${$2_REQ}; then
			AC_MSG_RESULT(no)
			unset HAS_$2
		else
			AC_MSG_RESULT(yes)
		fi
	fi
])


AC_DEFUN(
[AST_CHECK_PWLIB_BUILD], [
	if test "${HAS_$2:-unset}" != "unset"; then
	   AC_MSG_CHECKING($1 installation validity)

	   saved_cppflags="${CPPFLAGS}"
	   saved_libs="${LIBS}"
	   LIBS="${LIBS} -L${$2_LIBDIR} -l${PLATFORM_$2} $7"
	   CPPFLAGS="${CPPFLAGS} -I${$2_INCDIR} $6"

	   AC_LANG_PUSH([C++])

	   AC_LINK_IFELSE(
		[AC_LANG_PROGRAM([$4],[$5])],
		[	AC_MSG_RESULT(yes) 
			ac_cv_lib_$2="yes" 
		],
		[	AC_MSG_RESULT(no) 
			ac_cv_lib_$2="no" 
		]
		)

	   AC_LANG_POP([C++])

	   LIBS="${saved_libs}"
	   CPPFLAGS="${saved_cppflags}"

	   if test "${ac_cv_lib_$2}" = "yes"; then
	      if test "${$2_LIBDIR}" != "" -a "${$2_LIBDIR}" != "/usr/lib"; then
	         $2_LIB="-L${$2_LIBDIR} -l${PLATFORM_$2}"
	      else
	         $2_LIB="-l${PLATFORM_$2}"
	      fi
	      if test "${$2_INCDIR}" != "" -a "${$2_INCDIR}" != "/usr/include"; then
	         $2_INCLUDE="-I${$2_INCDIR}"
	      fi
	   	  PBX_$2=1
	   	  AC_DEFINE([HAVE_$2], 1, [$3])
	   fi
	fi
])

AC_DEFUN(
[AST_CHECK_OPENH323_BUILD], [
	if test "${HAS_OPENH323:-unset}" != "unset"; then
		AC_MSG_CHECKING(OpenH323 build option)
		OPENH323_SUFFIX=
		files=`ls -l ${OPENH323_LIBDIR}/libh323_${PWLIB_PLATFORM}_*.so*`
		libfile=
		if test -n "$files"; then
			for f in $files; do
				if test -f $f -a ! -L $f; then
					libfile=`basename $f`
					break;
				fi
			done
		fi
		if test "${libfile:-unset}" != "unset"; then
			OPENH323_SUFFIX=`eval "echo ${libfile} | sed -e 's/libh323_${PWLIB_PLATFORM}_\(@<:@^.@:>@*\)\..*/\1/'"`
		fi
		case "${OPENH323_SUFFIX}" in
			n)
				OPENH323_BUILD="notrace";;
			r)
				OPENH323_BUILD="opt";;
			d)
				OPENH323_BUILD="debug";;
			*)
				OPENH323_BUILD="notrace";;
		esac
		AC_MSG_RESULT(${OPENH323_BUILD})

		AC_SUBST([OPENH323_SUFFIX])
		AC_SUBST([OPENH323_BUILD])
	fi
])


# AST_FUNC_FORK
# -------------
AN_FUNCTION([fork],  [AST_FUNC_FORK])
AN_FUNCTION([vfork], [AST_FUNC_FORK])
AC_DEFUN([AST_FUNC_FORK],
[AC_REQUIRE([AC_TYPE_PID_T])dnl
AC_CHECK_HEADERS(vfork.h)
AC_CHECK_FUNCS(fork vfork)
if test "x$ac_cv_func_fork" = xyes; then
  _AST_FUNC_FORK
else
  ac_cv_func_fork_works=$ac_cv_func_fork
fi
if test "x$ac_cv_func_fork_works" = xcross; then
  case $host in
    *-*-amigaos* | *-*-msdosdjgpp* | *-*-uclinux* )
      # Override, as these systems have only a dummy fork() stub
      ac_cv_func_fork_works=no
      ;;
    *)
      ac_cv_func_fork_works=yes
      ;;
  esac
  AC_MSG_WARN([result $ac_cv_func_fork_works guessed because of cross compilation])
fi
ac_cv_func_vfork_works=$ac_cv_func_vfork
if test "x$ac_cv_func_vfork" = xyes; then
  _AC_FUNC_VFORK
fi;
if test "x$ac_cv_func_fork_works" = xcross; then
  ac_cv_func_vfork_works=$ac_cv_func_vfork
  AC_MSG_WARN([result $ac_cv_func_vfork_works guessed because of cross compilation])
fi

if test "x$ac_cv_func_vfork_works" = xyes; then
  AC_DEFINE(HAVE_WORKING_VFORK, 1, [Define to 1 if `vfork' works.])
else
  AC_DEFINE(vfork, fork, [Define as `fork' if `vfork' does not work.])
fi
if test "x$ac_cv_func_fork_works" = xyes; then
  AC_DEFINE(HAVE_WORKING_FORK, 1, [Define to 1 if `fork' works.])
fi
])# AST_FUNC_FORK


# _AST_FUNC_FORK
# -------------
AC_DEFUN([_AST_FUNC_FORK],
  [AC_CACHE_CHECK(for working fork, ac_cv_func_fork_works,
    [AC_RUN_IFELSE(
      [AC_LANG_PROGRAM([AC_INCLUDES_DEFAULT],
	[
	  /* By Ruediger Kuhlmann. */
	  return fork () < 0;
	])],
      [ac_cv_func_fork_works=yes],
      [ac_cv_func_fork_works=no],
      [ac_cv_func_fork_works=cross])])]
)# _AST_FUNC_FORK
