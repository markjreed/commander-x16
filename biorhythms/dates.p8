; A simple Prog8 library for manipulating dates around the present day
; in the Gregorian calendar.

; Copyright (c) 2024 Mark J. Reed.

; Released for public use under the MIT License
; (https://choosealicense.com/licenses/mit/)

%import conv
%import string

dates {

; This class deals with dates, not times; no time zones, no time of day, just
; calendar dates. These are represented as a word holding the number of days
; between the given date and day 0 = 2000-12-31. Since 2000 is a multiple of
; 400, that day 0 is the end of a full cycle in the Gregorian calendar, so the
; date counts the number of days into the next cycle. This keeps the math
; simple.

; The earliest representable date, -32768, corresponds to Saturday,
; April 15, 1911; the latest, +32767, corresponds to Sunday, September 17,
; 2090.

; There is no bounds checking. If you ask for a date outside the representable
; range, you'll get one wrapped into it. If you ask for March 40th, you will
; quietly get April 9th.

; Constructor:
;    date    = dates.new(year, month, day) ; construct a new date
;
; Accessors:
;    year    = dates.year(date)            ; year (CE)
;    month   = dates.month(date)           ; month (1-12)
;    day     = dates.day(date)             ; day of the month (1-31)
;    weekday = dates.weekday(date)         ; day of the week (0=Sun thru 6=Sat)
;    yday    = dates.yday(date)            ; day of the year (1-366)

; ISO 8601 week numbering:
;    iso_year  = dates.iso_year(date)      ; year per the ISO weekly calendar,
;                                          ; which may differ from year()
;                                          ; for dates around New Year's Day.
;    week_num    = dates.iso_week(date)    ; ISO week number, 1-53
;    iso_weekday = dates.iso_weekday(date) ; ISO weekday number (1=Mon thru 7=Sun)

; Format as string:
;    iso_str  = dates.iso_string(date, false, false) ; yyyy-mm-dd, e.g. 2024-04-12
;    isow_str = dates.iso_string(date, true, t/f)    ; yyyyWww-d,  e.g. 2024W15-5
;    long_str = dates.long_string(date, t/f)         ; long US format.
;    if t/f is false, no shifted letters.            ; e.g. Friday, April 12, 2024
;
; Utility functions:
;    is_leap  = dates.is_leap(year)         ; true if the given year is leap
;    is_long  = dates.is_long(year)         ; true if the given year is long
;                                             (has 53 weeks per ISO)

    ; potentially useful constants
    const uword MIN_YEAR   = 1911
    const uword MAX_YEAR   = 2090

    const ubyte SUNDAY     = 0
    const ubyte MONDAY     = SUNDAY + 1
    const ubyte TUESDAY    = SUNDAY + 2
    const ubyte WEDNESDAY  = SUNDAY + 3
    const ubyte THURSDAY   = SUNDAY + 4
    const ubyte FRIDAY     = SUNDAY + 5
    const ubyte SATURDAY   = SUNDAY + 6
    const ubyte ISO_SUNDAY = SUNDAY + 7

    ; these can be used in constructor calls, e.g.
    ; date = dates.new(1918, dates.NOVEMBER, 11)
    const ubyte JANUARY   = 1
    const ubyte FEBRUARY  = JANUARY + 1
    const ubyte MARCH     = JANUARY + 2
    const ubyte APRIL     = JANUARY + 3
    const ubyte MAY       = JANUARY + 4
    const ubyte JUNE      = JANUARY + 5
    const ubyte JULY      = JANUARY + 6
    const ubyte AUGUST    = JANUARY + 7
    const ubyte SEPTEMBER = JANUARY + 8
    const ubyte OCTOBER   = JANUARY + 9
    const ubyte NOVEMBER  = JANUARY + 10
    const ubyte DECEMBER  = JANUARY + 11

    ; construct a date object
    sub new(uword year, ubyte month, ubyte day) -> word {
        uword day_of_year = day + (month * 367 - 362)/12
        if month > 2 {
            day_of_year -= 2
            if is_leap(year) {
                day_of_year += 1
            }
        }

        word elapsed = (year as word) - 2001
        word common_days = elapsed * 365
        word leap_days = quotient(elapsed, 4)

        ; since the data type can't reach 100 years in either direction,
        ; we don't have to worry about the impact of non-leap
        ; centennial years and leap-after-all quadringentennial
        ; ones, which makes this simpler than usual
        word date = (day_of_year as word) + common_days + leap_days
        return date
    }

    ; extract the fields of a date object
    sub year(word date) -> uword {
        if date != cur_date {
            decode_date(date)
        }
        return cur_year
    }

    sub month(word date) -> ubyte {
        if date != cur_date {
            decode_date(date)
        }
        return cur_month
    }

    sub day(word date) -> ubyte {
        if date != cur_date {
            decode_date(date)
        }
        return cur_day
    }

    sub weekday(word date) -> ubyte {
        return remainder(date, 7) as ubyte
    }

    sub iso_weekday(word date) -> ubyte {
        ubyte wday = weekday(date)
        if wday == 0 wday = 7
        return wday
    }

    sub yday(word date) -> uword {
        return (date - new(year(date), 1, 1)) as uword + 1
    }

    ; true if the given year is leap in the Gregorian calendar
    sub is_leap(uword year) -> bool {
        if year &   3 != 0 return false
        if year % 100 != 0 return true
        return (year % 400 == 0)
    }

    ; true if the given ISO year has 53 weeks
    sub is_long(uword year) -> bool {
        word dec31 = new(year, 12, 31)
        word jan1  = new(year,  1,  1)
        return (weekday(jan1) == THURSDAY or weekday(dec31) == THURSDAY)
    }

    ; return the ISO year the given date belongs to,
    ; which may be different from the regular year
    ; for dates around January 1.
    sub iso_year(word date) -> uword {
        if date < -32507 {
            return MIN_YEAR
        }
        if date > 32508 {
            return MAX_YEAR
        }
        uword g_year = year(date)
        word jan4 = new(g_year, 1, 4)
        word week1 = jan4 - iso_weekday(jan4) + 1
        if date < week1 return g_year - 1
        jan4 = new(g_year + 1, 1, 4)
        week1 = jan4 - iso_weekday(jan4) + 1
        if date > week1 return g_year + 1
        return g_year
    }

    sub iso_week(word date) -> ubyte {
        if date < -32507 {
            ; start of 1911 is too far back to reckon from
            if date < -32766 {
                return 15
            }
            return quotient(date + 32766, 7) as ubyte + 16
        }

        word jan4 = new(year(date), 1, 4)
        word week1 = jan4 - iso_weekday(jan4) + 1
        if week1 > date {
            cur_year -= 1
            jan4 = new(cur_year, 1, 4)
            week1 = jan4 - iso_weekday(jan4) + 1
        }
        ubyte week = quotient(date - week1, 7) as ubyte + 1
        if week == 53 and not is_long(cur_year) {
            week = 1
        }
        return week
    }

    sub iso_string(word date, bool weekly, bool mixed_case) -> uword {
        uword buffer = date_string
        if weekly {
            buffer += string.copy(conv.str_uw(iso_year(date)), buffer)
            if mixed_case {
                @(buffer) = 'W'
            } else {
                @(buffer) = 'w'
            }
            buffer++
            str_ub2(iso_week(date), buffer) buffer += 2
            @(buffer) = '-' buffer++
            @(buffer) = iso_weekday(date) + '0' buffer++
            @(buffer) = 0
        } else {
            buffer += string.copy(conv.str_uw(year(date)), buffer)
            @(buffer) = '-' buffer++
            str_ub2(month(date), buffer) buffer += 2
            @(buffer) = '-' buffer++
            str_ub2(day(date), buffer)
        }
        return date_string
    }

    sub long_string(word date, bool mixed_case) -> uword {
        if date != cur_date {
            decode_date(date)
        }
        uword buffer = date_string
        buffer += string.copy(weekday_name(weekday(date), mixed_case), buffer)
        buffer += string.copy(", ", buffer)
        buffer += string.copy(month_name(cur_month, mixed_case), buffer)
        @(buffer) = ' '   buffer ++
        buffer += string.copy(conv.str_ub(cur_day), buffer)
        buffer += string.copy(", ", buffer)
        void string.copy(conv.str_uw(cur_year), buffer)
        return date_string
    }

    ;; end public API
    ; internal variables
    ; cache of the most recently decoded date, so we don't have to decode it
    ; again to get other fields
    word  cur_date
    uword cur_year  = 2000
    ubyte cur_month = 12
    ubyte cur_day   = 31

    ; buffer for building string representations
    ubyte[30] date_string

    ; helper routines
    sub decode_date(word date) {
        cur_date = date
        bool in_min_year = false
        bool in_max_year = false

        ; special-case the extremes since the arithmetic gets tricky
        if date < -32507 {
            in_min_year = true
            date += 366
        }

        if date > 32507 {
            in_max_year = true
            date -= 365
        }

        ; again, due to the restricted range, we don't have to worry
        ; about 146097-day quadringenturies or 36524-day centuries;
        ; the only multiyear period that matters is the 1461-day
        ; olympiad of four years
        word olympiads = quotient(date, 1461)
        word rest      = remainder(date, 1461)
        word current   = quotient(rest,  365)
        cur_year = (2000 + olympiads * 4 + current) as uword

        if cur_year <= MIN_YEAR {
            cur_year = MIN_YEAR + 1
        } else if cur_year >= MAX_YEAR {
            cur_year = MAX_YEAR - 1
        }

        word jan1 = new(cur_year, 1, 1)

        while jan1 > date {
            cur_year -= 1
            jan1 = new(cur_year, 1, 1)
        }
        word next  = new(cur_year+1, 1, 1)
        while date >= next {
            cur_year += 1
            jan1 = next
            next  = new(cur_year+1, 1, 1)
        }

        word mar1 = new(cur_year, 3, 1)
        uword correction
        if date < mar1 {
            correction = 0
        } else if is_leap(cur_year) {
            correction = 1
        } else {
            correction = 2
        }
        uword prior_days = date - jan1 as uword
        cur_month = lsb((12 * (prior_days + correction) + 373) / 367)
        cur_day = lsb(date - new(cur_year, cur_month, 1) + 1)
        if in_min_year {
            cur_year = MIN_YEAR
            date -= 366
        } else if in_max_year {
            cur_year = MAX_YEAR
            date += 365
        }
    }

    ubyte[10] name_buffer
    sub weekday_name(ubyte weekday, bool mixed_case) -> str {
        str[7] weekday_names = [ "Sunday", "Monday", "Tuesday", "Wednesday",
                                 "Thursday", "Friday", "Saturday" ]
        void string.copy(weekday_names[weekday], name_buffer)
        if not mixed_case {
            name_buffer[0] = name_buffer[0] - 'A' + 'a'
        }
        return name_buffer
    }

    sub month_name(ubyte month, bool mixed_case) -> str {
        str[12] month_names = [ "January",   "February", "March",    "April",
                                "May",       "June",     "July",     "August",
                                "September", "October",  "November", "December"
                              ]
        void string.copy(month_names[month - 1], name_buffer)
        if not mixed_case {
            name_buffer[0] = name_buffer[0] - 'A' + 'a'
        }
        return name_buffer
    }

    ; print a value < 100 in 2 places, with a leading 0 if < 10
    sub str_ub2(ubyte value, uword addr) {
        void string.copy(conv.str_ub0(value)+1, addr)
    }

    ; a version of divmod that works on negative numbers.
    ; quotient is always floor(a/b), even if a/b is negative.
    ; remainder is therefore always positive for positive divisors.

    word saved_dividend
    word saved_divisor
    word saved_quotient
    word saved_remainder

    sub do_divmod(word dividend, word divisor) {
         saved_dividend = dividend
         saved_divisor  = divisor

         if dividend == 0 {
             saved_quotient = 0
             saved_remainder = 0
             return
         }

         bool num_pos = dividend  >= 0
         bool den_pos = divisor   >  0

         saved_quotient = dividend / divisor

         if ((saved_quotient < 0) or
             (saved_quotient == 0) and (num_pos != den_pos))
            and
             (saved_quotient * divisor != dividend) {
             saved_quotient -= 1
         }

         saved_remainder = dividend - divisor * saved_quotient
    }

    sub quotient(word dividend, word divisor) -> word {
        if dividend != saved_dividend or divisor != saved_divisor {
            do_divmod(dividend, divisor)
        }
        return saved_quotient
    }

    ; an integer remainder routine that always returns floor(a/b),
    ; even if a/b is negative.
    sub remainder(word dividend, word divisor) -> word {
        if dividend != saved_dividend or divisor != saved_divisor {
            do_divmod(dividend, divisor)
        }
        return saved_remainder
    }
}
