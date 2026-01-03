/*
 * CINUX
 * Copyright (C) 2025-2026 Connor Thomson
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 3 of the License.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

void kmemmove(unsigned char *dst, const unsigned char *src, unsigned int n) {
    if (dst < src) {
        unsigned int i;
        for (i = 0; i < n; i++)
            dst[i] = src[i];
    } else {
        unsigned int i;
        for (i = n; i > 0; i--)
            dst[i - 1] = src[i - 1];
    }
}

void kmemset(unsigned char *dst, unsigned char val, unsigned int n) {
    unsigned int i;
    for (i = 0; i < n; i++)
        dst[i] = val;
}
