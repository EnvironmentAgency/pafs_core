# Play nice with Ruby 3 (and rubocop)
# frozen_string_literal: true
module PafsCore
  PSO_TO_COASTAL_GROUP_MAP = {
    "PSO Durham & Tees Valley"                    => "North East Coastal Group",
    "PSO Tyne and Wear & Northumberland"          => "North East Coastal Group",
    "PSO Cumbria"                                 => "North West Coastal Group",
    "PSO Lancashire"                              => "North West Coastal Group",
    "PSO East Yorkshire"                          => "North East Coastal Group",
    "PSO North Yorkshire"                         => "North East Coastal Group",
    "PSO Notts & Tidal"                           => "Trent North East Coastal Group",
    "PSO Coastal Lincolnshire & Northamptonshire" => "North East Coastal Group",
    "PSO Lincolnshire"                            => "North East Coastal Group",
    "PSO Cheshire & Merseyside"                   => "North West Coastal Group",
    "PSO Dorset & Wiltshire"                      => "Southern Coastal Group",
    "PSO Somerset"                                => "Severn Estuary Coastal Group",
    "PSO West of England"                         => "Severn Estuary Coastal Group",
    "PSO East Devon & Cornwall"                   => "South West Coastal Group",
    "PSO Cambridge & Bedfordshire"                => "East Anglia Coastal Group",
    "PSO Coastal Essex, Suffolk & Norfolk"        => "East Anglia Coastal Group",
    "PSO Essex"                                   => "East Anglia Coastal Group",
    "PSO Norfolk & Suffolk"                       => "East Anglia Coastal Group",
    "PSO Luton, Herts & Essex"                    => "East Anglia Coastal Group",
    "PSO East Sussex"                             => "South East Coastal Group",
    "PSO Hampshire & Isle of Wight"               => "Southern Coastal Group",
    "PSO West Sussex"                             => "South East Coastal Group",
    "PSO East Kent"                               => "South East Coastal Group",
    "PSO West Kent"                               => "South East Coastal Group",
  }.freeze
end
