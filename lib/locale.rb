module OLD
  module SITE
    CN = :cn
    EN = :www
    ES = :es
    FR = :fr
    JP = :ja
    KO = :ko
    PL = :pl
    RU = :ru
    TH = :th

    def self.all
      self.constants.map do |name|
        self.const_get(name)
      end
    end

    def self.create(obj)
      map = {
        "cn" => CN,
        "en" => EN,
        "es" => ES,
        "fr" => FR,
        "jp" => JP,
        "ko" => KO,
        "pl" => PL,
        "ru" => RU,
        "th" => TH
      }
      map[obj]
    end
  end

  def get_endpoint(site)
    case site
    when SITE::CN
      "www.scp-wiki-cn.org"
    when SITE::ES
      "lafundacionscp.wikidot.com"
    when SITE::FR
      "fondationscp.wikidot.com"
    when SITE::PL, SITE::TH
      "scp-#{site.to_s}.wikidot.com"
    when SITE::RU
      "scpfoundation.ru"
    else
      "#{site.to_s}.scp-wiki.net"
    end
  end

  def get_locale(site)
    case site
    when SITE::CN
      "zh_CN"
    when SITE::EN
      ""
    else
      site.to_s
    end
  end
end
