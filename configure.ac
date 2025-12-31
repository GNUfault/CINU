dnl CINUX
dnl Copyright (C) 2025 Connor Thomson
dnl
dnl This program is free software: you can redistribute it and/or modify
dnl it under the terms of the GNU General Public License as published by
dnl the Free Software Foundation, either version 3 of the License, or
dnl any later version.
dnl
dnl This program is distributed in the hope that it will be useful,
dnl but WITHOUT ANY WARRANTY; without even the implied warranty of
dnl MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
dnl GNU General Public License for more details.
dnl
dnl You should have received a copy of the GNU General Public License
dnl along with this program. If not, see <https://www.gnu.org/licenses/>

AC_INIT([CINUX], [0.0.0])
AM_INIT_AUTOMAKE([foreign no-dependencies])

AC_PROG_CC
AM_PROG_AS

AC_ARG_ENABLE([grub],
  [AS_HELP_STRING([--disable-grub], [Disable the ISO and output only the ELF])],
  [enable_grub="$enableval"],
  [enable_grub="yes"])

AS_IF([test "x$enable_grub" = "xyes"], [
  AC_PATH_PROG([GRUB_MKRESCUE], [grub-mkrescue])
  AS_IF([test "x$GRUB_MKRESCUE" = "x"], [AC_MSG_ERROR([grub-mkrescue not found.])])

  AC_PATH_PROG([GRUB_MKIMAGE], [grub-mkimage])
  AS_IF([test "x$GRUB_MKIMAGE" = "x"], [AC_MSG_ERROR([grub-mkimage not found.])])

  AC_PATH_PROG([XORRISO], [xorriso])
  AS_IF([test "x$XORRISO" = "x"], [AC_MSG_ERROR([xorriso not found.])])

  AC_PATH_PROG([MFORMAT], [mformat])
  AC_PATH_PROG([MCOPY], [mcopy])
])

AM_CONDITIONAL([USE_GRUB], [test "x$enable_grub" = "xyes"])

AC_ARG_WITH([iso],
  [AS_HELP_STRING([--with-iso=NAME], [Set the ISO filename])],
  [ISO="$withval"],
  [ISO="cinux.iso"])

AC_ARG_WITH([kernel],
  [AS_HELP_STRING([--with-kernel=NAME], [Set the kernel filename])],
  [KERNEL="$withval"],
  [KERNEL="cinux.elf"])

AC_SUBST([ISO])
AC_SUBST([KERNEL])
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
