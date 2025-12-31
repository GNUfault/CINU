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
AM_INIT_AUTOMAKE([foreign])

AC_PROG_CC
AM_PROG_AS

AC_PATH_PROG([GRUB_MKIMAGE], [grub-mkimage])
AS_IF([test "x$GRUB_MKIMAGE" = "x"],
  [AC_MSG_ERROR([grub-mkimage not found. Please install GRUB2 development tools.])])

AC_ARG_WITH([iso],
  [AS_HELP_STRING([--with-iso=NAME], [Set the output ISO filename])],
  [ISO="$withval"],
  [ISO="cinux.iso"])

AC_SUBST([ISO])

AC_CONFIG_FILES([Makefile])
AC_OUTPUT
