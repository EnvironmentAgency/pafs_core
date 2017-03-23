# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  RFCC_CODES = %w[ AC AE AN NO NW SN SO SW TH TR TS WX YO ].freeze

  # map RFCC codes to names

  RFCC_CODE_NAMES_MAP = {
    "AC" => "Anglian Central",
    "AE" => "Anglian Eastern",
    "AN" => "Anglian Northern",
    "NO" => "Northumbria",
    "NW" => "North West",
    "SO" => "Southern",
    "SN" => "Severn & Wye",
    "SW" => "Southwest",
    "TH" => "Thames",
    "TR" => "Trent",
    "TS" => "Test",
    "WX" => "Wessex",
    "YO" => "Yorkshire",
  }.freeze

  # map PSO areas to RFCC codes
  PSO_RFCC_MAP = {
    "PSO Berkshire & Buckinghamshire"                     => "TH",
    "PSO Cambridge & Bedfordshire"                        => "AC",
    "PSO Cheshire & Merseyside"                           => "NW",
    "PSO Coastal Essex, Suffolk & Norfolk"                => "AE",
    "PSO Coastal Lincolnshire & Northamptonshire"         => "AN",
    "PSO Cumbria"                                         => "NW",
    "PSO Derbyshire & Leicestershire"                     => "TR",
    "PSO Dorset & Wiltshire"                              => "WX",
    "PSO Durham & Tees Valley"                            => "NO",
    "PSO East Devon & Cornwall"                           => "SW",
    "PSO East Kent"                                       => "SO",
    "PSO East Sussex"                                     => "SO",
    "PSO East Yorkshire"                                  => "YO",
    "PSO Essex"                                           => "AE",
    "PSO Greater Manchester"                              => "NW",
    "PSO Hampshire & Isle of Wight"                       => "SO",
    "PSO Herefordshire & Gloucestershire"                 => "SN",
    "PSO Lancashire"                                      => "NW",
    "PSO Lincolnshire"                                    => "AN",
    "PSO London East"                                     => "TH",
    "PSO London West"                                     => "TH",
    "PSO Luton, Herts & Essex"                            => "TH",
    "PSO Norfolk & Suffolk"                               => "AE",
    "PSO North Staffordshire & the Black Country"         => "TR",
    "PSO North Yorkshire"                                 => "YO",
    "PSO Notts & Tidal Trent"                             => "TR",
    "PSO Oxfordshire"                                     => "TH",
    "PSO SE London & North Kent"                          => "TH",
    "PSO Shropshire, Worcestershire Telford & Wrekin"     => "SN",
    "PSO Somerset"                                        => "WX",
    "PSO South West London & Mole"                        => "TH",
    "PSO South Yorkshire"                                 => "YO",
    "PSO Test Area"                                       => "TS",
    "PSO Tyne and Wear & Northumberland"                  => "NO",
    "PSO Warwickshire, Birmingham, Solihull & Coventry"   => "SN",
    "PSO Welland & Nene"                                  => "AN",
    "PSO West Devon & Cornwall"                           => "SW",
    "PSO West Kent"                                       => "SO",
    "PSO West Sussex"                                     => "SO",
    "PSO West Yorkshire"                                  => "YO",
    "PSO West of England"                                 => "WX"
  }.freeze
end
