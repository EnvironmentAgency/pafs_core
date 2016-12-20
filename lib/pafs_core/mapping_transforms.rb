# frozen_string_literal: true
module PafsCore
  module MappingTransforms
    NGR_CODES = [
      %w[ HL HM HN HO HP JL JM JN ],
      %w[ HQ HR HS HT HU JQ JR JS ],
      %w[ HV HW HX HY HZ JV JW JX ],
      %w[ NA NB NC ND NE OA OB OC ],
      %w[ NF NG NH NJ NK OF OG OH ],
      %w[ NL NM NN NO NP OL OM ON ],
      %w[ NQ NR NS NT NU OQ OR OS ],
      %w[ NV NW NX NY NZ OV OW OX ],
      %w[ SA SB SC SD SE TA TB TC ],
      %w[ SF SG SH SJ SK TF TG TH ],
      %w[ SL SM SN SO SP TL TM TN ],
      %w[ SQ SR SS ST SU TQ TR TS ],
      %w[ SV SW SX SY SZ TV TW TX ]
    ].reverse.freeze

    def code_map
      @code_map ||= build_code_map
    end

    def build_code_map
      map = {}
      NGR_CODES.each_with_index do |r, north|
        r.each_with_index do |c, east|
          map[c] = [east, north]
        end
      end
      map
    end

    # Get OS Grid ref part (2 letters at the start)
    def get_os_grid_ref(grid_ref)
      code_map.fetch(grid_ref[0..1], nil) unless grid_ref.nil?
    end

    # Converts OS National Grid Reference to easting/northing
    # grid_ref should be upper case and not contain spaces
    def grid_reference_to_eastings_and_northings(grid_ref)
      gr = get_os_grid_ref(grid_ref)
      unless gr.nil?
        n = grid_ref[2..-1]
        hl = n.length / 2
        {
          easting: "#{gr[0]}#{n[0..hl - 1]}".ljust(6, "0").to_i,
          northing: "#{gr[1]}#{n[hl..-1]}".ljust(6, "0").to_i
        }
      end
    end

    # Converts easting/northing coords into WGS84 latitude/longitude
    def easting_northing_to_latitude_longitude(easting, northing)
      osgb36 = easting_northing_to_osgb36(easting, northing)
      osgb36_to_wgs84(osgb36[:latitude], osgb36[:longitude])
    end

    # rubocop:disable Style/SpaceAroundOperators, Style/ExtraSpacing, Metrics/AbcSize
    # Converts easting/northing coords into OSGB36 latitude/longitude
    def easting_northing_to_osgb36(easting, northing)
      osbg_f0   = 0.9996012717
      n0        = -100000.0
      e0        = 400000.0
      phi0      = deg_to_rad(49.0)
      lambda0   = deg_to_rad(-2.0)
      _a        = 6377563.396
      _b        = 6356256.909
      e_squared = ((_a * _a) - (_b * _b)) / (_a * _a)
      _phi      = 0.0
      _lambda   = 0.0
      est       = easting
      nrth      = northing
      _n        = (_a - _b) / (_a + _b)
      _m        = 0.0
      phi_prime = ((nrth - n0) / (_a * osbg_f0)) + phi0

      begin
        _m = (_b * osbg_f0)\
          * (((1 + _n + ((5.0 / 4.0) * _n * _n) + ((5.0 / 4.0) * _n * _n * _n))\
              * (phi_prime - phi0))\
          - (((3 * _n) + (3 * _n * _n) + ((21.0 / 8.0) * _n * _n * _n))\
             * Math.sin(phi_prime - phi0)\
             * Math.cos(phi_prime + phi0))\
          + ((((15.0 / 8.0) * _n * _n) + ((15.0 / 8.0) * _n * _n * _n))\
             * Math.sin(2.0 * (phi_prime - phi0))\
             * Math.cos(2.0 * (phi_prime + phi0)))\
          - (((35.0 / 24.0) * _n * _n * _n)\
             * Math.sin(3.0 * (phi_prime - phi0))\
             * Math.cos(3.0 * (phi_prime + phi0))))

        phi_prime += (nrth - n0 - _m) / (_a * osbg_f0)
      end while ((nrth - n0 - _m) >= 0.001)

      _v = _a * osbg_f0 * ((1.0 - e_squared * sin_pow_2(phi_prime)) ** -0.5)
      _rho = _a * osbg_f0 * (1.0 - e_squared) * ((1.0 - e_squared * sin_pow_2(phi_prime)) ** -1.5)

      eta_squared = (_v / _rho) - 1.0

      _vii = Math.tan(phi_prime) / (2 * _rho * _v)

      _viii = (Math.tan(phi_prime) / (24.0 * _rho * (_v ** 3.0))) *
              (5.0 + (3.0 * tan_pow_2(phi_prime)) + eta_squared -
              (9.0 * tan_pow_2(phi_prime) * eta_squared))

      _ix = (Math.tan(phi_prime) / (720.0 * _rho * (_v ** 5.0))) *
            (61.0 + (90.0 * tan_pow_2(phi_prime)) + (45.0 * tan_pow_2(phi_prime) *
            tan_pow_2(phi_prime)))

      _x = sec(phi_prime) / _v

      _xi = (sec(phi_prime) / (6.0 * _v * _v * _v)) *
            ((_v / _rho) + (2 * tan_pow_2(phi_prime)))

      _xii = (sec(phi_prime) / (120.0 * (_v ** 5.0))) *
             (5.0 + (28.0 * tan_pow_2(phi_prime)) + (24.0 * tan_pow_2(phi_prime) *
             tan_pow_2(phi_prime)))

      _xiia = (sec(phi_prime) / (5040.0 * (_v ** 7.0))) *
              (61.0 + (662.0 * tan_pow_2(phi_prime)) +
              (1320.0 * tan_pow_2(phi_prime) * tan_pow_2(phi_prime)) +
              (720.0 * tan_pow_2(phi_prime) * tan_pow_2(phi_prime) *
              tan_pow_2(phi_prime)))

      _phi = phi_prime - (_vii * ((est - e0) ** 2.0)) +
             (_viii * ((est - e0) ** 4.0)) - (_ix * ((est - e0) ** 6.0))

      _lambda = lambda0 + (_x * (est - e0)) - (_xi * ((est - e0) ** 3.0)) +
                (_xii * ((est - e0) ** 5.0)) - (_xiia * ((est - e0) ** 7.0))

      { latitude: rad_to_deg(_phi), longitude: rad_to_deg(_lambda) }
    end

    # Convert OSGB36 latitude/longitude coords
    # into WGS84 latitude/longitude
    def osgb36_to_wgs84(latitude, longitude)
      _a        = 6377563.396
      _b        = 6356256.909
      e_squared = ((_a * _a) - (_b * _b)) / (_a * _a)

      _phi = deg_to_rad(latitude)
      _lambda = deg_to_rad(longitude)
      _v = _a / Math.sqrt(1 - e_squared * sin_pow_2(_phi))
      _h = 0
      _x = (_v + _h) * Math.cos(_phi) * Math.cos(_lambda)
      _y = (_v + _h) * Math.cos(_phi) * Math.sin(_lambda)
      _z = ((1 - e_squared) * _v + _h) * Math.sin(_phi)

      _tx =        446.448
      _ty =       -124.157
      _tz =        542.060

      _s  =         -0.0000204894
      _rx = deg_to_rad(0.00004172222)
      _ry = deg_to_rad(0.00006861111)
      _rz = deg_to_rad(0.00023391666)

      _xb = _tx + (_x * (1 + _s)) + (-_rx * _y)     + (_ry * _z)
      _yb = _ty + (_rz * _x)      + (_y * (1 + _s)) + (-_rx * _z)
      _zb = _tz + (-_ry * _x)     + (_rx * _y)      + (_z * (1 + _s))

      _a        = 6378137.000
      _b        = 6356752.3141
      e_squared = ((_a * _a) - (_b * _b)) / (_a * _a)

      _lambda_b = rad_to_deg(Math.atan(_yb / _xb))
      _p = Math.sqrt((_xb * _xb) + (_yb * _yb))
      _phi_n = Math.atan(_zb / (_p * (1 - e_squared)))

      (1..10).each do |_i|
        _v = _a / Math.sqrt(1 - e_squared * sin_pow_2(_phi_n))
        _phi_n1 = Math.atan((_zb + (e_squared * _v * Math.sin(_phi_n))) / _p)
        _phi_n = _phi_n1
      end

      _phi_b = rad_to_deg(_phi_n)

      { latitude: _phi_b.round(6), longitude: _lambda_b.round(6) }
    end
    # rubocop:enable Style/SpaceAroundOperators, Style/ExtraSpacing, Metrics/AbcSize

    private # Some math helpers

    def deg_to_rad(degrees)
      degrees / 180.0 * Math::PI
    end

    def rad_to_deg(r)
      (r / Math::PI) * 180
    end

    def sin_pow_2(x)
      Math.sin(x) * Math.sin(x)
    end

    def cos_pow_2(x)
      Math.cos(x) * Math.cos(x)
    end

    def tan_pow_2(x)
      Math.tan(x) * Math.tan(x)
    end

    def sec(x)
      1.0 / Math.cos(x)
    end
  end
end
