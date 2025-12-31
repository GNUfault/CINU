AC_INIT([CINUX], [0.0.0])
AM_INIT_AUTOMAKE([foreign])

AC_PATH_PROG([GRUB_MKIMAGE], [grub-mkimage])
AS_IF([test "x$GRUB_MKIMAGE" = "x"],
  [AC_MSG_ERROR([grub-mkimage not found. Please install GRUB2 development tools.])])

AC_ARG_WITH([iso],
  [AS_HELP_STRING([--with-iso=NAME], [Set the output ISO filename])],
  [ISO_NAME="$withval"],
  [ISO_NAME="cinux.iso"])

AC_SUBST([ISO_NAME])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
