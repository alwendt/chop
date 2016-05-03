#define REGBITS		32		/* size of allocation mask	*/

#define MAX_REGBITS	2		/* max width of any register	*/
					/* in bits of allocation mask	*/

extern unsign32 freebies, savemask;

/* Define this if most significant byte of a word is the lowest numbered.  */
/* That is true on the 68000.  */
#define BYTES_BIG_ENDIAN
