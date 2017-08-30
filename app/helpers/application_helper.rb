module ApplicationHelper

  def persian_numbers(str)
    str ? str.to_s.unpack('U*').map{ |e| (0..9).to_a.include?(e-48) ? e + 1728 : e }.pack('U*') : ''
  end

  def persian_date(date)
    date ? persian_numbers(JalaliDate.new(date).format("%A %e %b %Y - %H:%M")) : ''
  end

  def persian_date_month(date)
    date ? persian_numbers(JalaliDate.new(date).format("%b %Y")) : ''
  end

  def persian_date_bare(date)
    date ? persian_numbers(JalaliDate.new(date).format("%Y/%m/%d")) : ''
  end

  def persian_days_of_week(i)
    [
      'شنبه',
      'یکشنبه',
      'دوشنبه',
      'سه‌شنبه',
      'چهارشنبه',
      'پنجشنبه',
      'جمعه',
    ][i]
  end

  def to_hours(hs)
    hours = hs.floor
    minutes = ((hs - hours)*60).floor
    "#{hours}:"+(minutes < 10 ? "0#{minutes}" : "#{minutes}")
  end

  def persian_months
    {
      'فروردین'   =>  1,
      'اردیبهشت'  =>  2,
      'خرداد'     =>  3,
      'تیر'       =>  4,
      'مرداد'     =>  5,
      'شهریور'    =>  6,
      'مهر'       =>  7,
      'آبان'      =>  8,
      'آذر'       =>  9,
      'دی'        => 10,
      'بهمن'      => 11,
      'اسفند'     => 12 
    }
  end

  def persian_days
    (1..31).to_a.map{|i| {persian_numbers(i.to_s) => i.to_s}}.reduce({}, :merge)
  end

  def persian_years
    today = JalaliDate.today
    y = today.year
    (y-1..y+1).map{|y2| { persian_numbers(y2.to_s) => y2.to_s} }.reduce({}, :merge)
    # { persian_numbers(y.to_s) => y.to_s, persian_numbers((y+1).to_s) => (y+1).to_s}
    # if today.month < 7
    #   { persian_numbers(y.to_s) => y.to_s}
    # else
    #   { persian_numbers(y.to_s) => y.to_s, persian_numbers((y+1).to_s) => (y+1).to_s}
    # end
  end

  def flash_class(level)
    case level
    when :notice then "alert alert-info"
    when :success then "alert alert-success"
    when :error then "alert alert-danger"
    when :alert then "alert alert-warning"
    end
  end

  def title(page_title)
    content_for :title, I18n.t('site_title')+" :‌ "+page_title.to_s
  end

  def user_types(curr_type)
    types = {
      0 => "کاربر عادی",
      1 => "اپراتور",
      2 => "ادمین",
      3 => "ادمین کلی",
    }
    types.select{|k,t| k<curr_type}.invert
  end

  def user_type_string(curr_type)
    types = {
      0 => "کاربر عادی",
      1 => "اپراتور",
      2 => "ادمین",
      3 => "ادمین کلی",
    }
    if( curr_type<4 && curr_type>=0 )
      return types[curr_type]
    end
    return "";
  end

  def range_options
    {
      "دوره نمونه برداری" => 0,
      "۱ دقیقه" => 1,
      "۵ دقیقه" => 2,
      "۱۰ دقیقه" => 3,
      "۲۰ دقیقه" => 4,
      "۳۰ دقیقه" => 5,
      "۱ ساعت" => 6,
      "۲ ساعت" => 7,
      "۵ ساعت" => 8,
      "۱ روز" => 9,
    }
  end
  def average_options
    {
      "متوسط" => 0,
      "سرزمان" => 1,
      "بیشترین" => 2,
      "کمترین" => 3
    }
  end

end
