#import "@preview/nth:0.2.0": nth

#let ndaysfromdate(n, date: datetime.today()) = {
  let newdate = date.ordinal() + n;
  let year = date.year();
  let leapyear = calc.rem(year, 4);
  
  if (newdate <= 0) and (newdate + 365 > 0) {
    year = year - 1;
    if leapyear != 0 {
      newdate = 365 + newdate;
    } else {
      newdate = 366 + newdate;
    }
  }

  if leapyear != 0 {
    if (newdate > 365) and (newdate < 731) {
      newdate = newdate - 365;
      year = year + 1;
    }
  } else {
    if (newdate > 366) and (newdate < 732) {
      newdate = newdate - 366;
      year = year + 1;
    }
  }
  
  let monthdays = (
    31, //Jan
    if  leapyear !=0 {28} else {29}, //Feb
    31, //Mar
    30, //Apr
    31, //May
    30, //Jun
    31, //Jul
    31, //Aug
    30, //Sep
    31, //Oct
    30, //Nov
    31  //Dec
  )
  
  let monthnum = 0;
  let daynum = newdate;
  
  if (newdate > 730) or (newdate + 365 < 0) {
      text(red)[*The package currently only works for that the expected date is Between January 1st of last year and December 31 of the next year.*];
      return {today}
  } else {
    while monthdays.at(monthnum) < daynum {
      daynum = daynum - monthdays.at(monthnum);
      monthnum = monthnum + 1;
    }
  }
  return {datetime(
      year: year,
      month: monthnum + 1,
      day: daynum,
    )}
}


#let tomorrow = {ndaysfromdate(1)}

#let todaysweekday = {datetime.today().weekday()}

#let monday = {
  ndaysfromdate(1-todaysweekday)
}
#let tuesday = {
  ndaysfromdate(2-todaysweekday)
}
#let wednesday = {
  ndaysfromdate(3-todaysweekday)
}
#let thursday = {
  ndaysfromdate(4-todaysweekday)
}
#let friday = {
  ndaysfromdate(5-todaysweekday)
}

#let nextmonday = {
  ndaysfromdate(8-todaysweekday)
}
#let nexttuesday = {
  ndaysfromdate(9-todaysweekday)
}
#let nextwednesday = {
  ndaysfromdate(10-todaysweekday)
}
#let nextthursday = {
  ndaysfromdate(11-todaysweekday)
}
#let nextfriday = {
  ndaysfromdate(12-todaysweekday)
}

#let nameweekday(date) = {
("Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday").at(date.weekday()-1)
}

#let namemonth(date) = {
("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" ).at(date - 1)
}

// pattern: s or L = 
// region: date display convention
#let datedisp(
  weekdayname: true,
  numerical: false, 
  region: "en-US",
  date
) = {
  if type(date) != "datetime" { 
    date 
  } else { 
    if weekdayname {
      nameweekday(date)
      [,]
      h(0.25em)
    }
    if region == "en-US" {
          if numerical {
            date.display("[month]/[day]/[year]")
          } else [
              #namemonth(date.month())
              #nth(date.day()),
              #date.year()
           ]
    }
    if region == "zh-CN" {
      if numberical {
        date.display("[year]/[month]/[day]")
      } else {
        date.display("[year] 年 [month] 月 [day] 日")
      }
    }
  }
}

#let semester(date) = {
  let semestername = {
    if date.month() == 1  {
      "Winter"
    } else if date.month() < 6 {
      "Spring"
    } else if date.month() < 8  {
      "Summer"
    } else {
      "Fall"
    }
  }
  semestername + " " + str(date.year())
}