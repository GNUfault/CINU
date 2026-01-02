dnl CINUX
dnl Copyright (C) 2025-2026 Connor Thomson
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

dnl We don't have version numbers yet
AC_INIT([CINUX], [0.0.0])

dnl CINUX is freestanding, it doesn't need any dependencies
AM_INIT_AUTOMAKE([foreign no-dependencies])

dnl Check for compiler
AC_PROG_CC

dnl Check for assembler
AM_PROG_AS

dnl Allow user to change floppy diskette name
AC_ARG_WITH([floppy],
  [AS_HELP_STRING([--with-floppy=NAME], [Set the floppy filename])],
  [FLOPPY="$withval"],
  [FLOPPY="cinux.img"])

dnl Pass over $(FLOPPY)
AC_SUBST([FLOPPY])

dnl Configure Makefile
AC_CONFIG_FILES([Makefile])

dnl Output it
AC_OUTPUT
