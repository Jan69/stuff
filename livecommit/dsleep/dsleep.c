#define _POSIX_C_SOURCE 200112L
#include <time.h>
#include <errno.h>
/* copied from https://stackoverflow.com/questions/29243572/how-to-pause-for-a-non-integer-amount-of-time-in-c/29260846#29260846 */

double dsleep(const double seconds)
{
    const long  sec = (long)seconds;
    const long  nsec = (long)((seconds - (double)sec) * 1e9);
    struct timespec  req, rem;

    if (sec < 0L)
        return 0.0;
    if (sec == 0L && nsec <= 0L)
        return 0.0;

    req.tv_sec = sec;
    if (nsec <= 0L)
        req.tv_nsec = 0L;
    else
    if (nsec <= 999999999L)
        req.tv_nsec = nsec;
    else
        req.tv_nsec = 999999999L;

    rem.tv_sec = 0;
    rem.tv_nsec = 0;

    if (nanosleep(&req, &rem) == -1) {
        if (errno == EINTR)
            return (double)rem.tv_sec + (double)rem.tv_nsec / 1000000000.0;
        else
            return seconds;
    } else
        return 0.0;
}
