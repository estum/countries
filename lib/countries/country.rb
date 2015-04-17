module ISO3166; end

class ISO3166::Country
  Codes = YAML.load_file(File.expand_path('../../data/countries.yaml', __FILE__)).freeze
  Data = {}
  Codes.each { |alpha2| Data[alpha2] = YAML.load_file(File.expand_path("../../data/countries/#{alpha2}.yaml", __FILE__))[alpha2].freeze }
  # Names = I18nData.countries.values.sort_by! { |d| d[0] }.freeze

  AttrReaders = [
    :number,
    :alpha2,
    :alpha3,
    :name,
    :names,
    :latitude,
    :longitude,
    :continent,
    :region,
    :subregion,
    :world_region,
    :country_code,
    :national_destination_code_lengths,
    :national_number_lengths,
    :international_prefix,
    :national_prefix,
    :address_format,
    :ioc,
    :gec,
    :un_locode,
    :languages,
    :nationality,
    :dissolved_on,
    :eu_member,
    :postal_code,
    :min_longitude,
    :min_latitude,
    :max_longitude,
    :max_latitude,
    :latitude_dec,
    :longitude_dec
  ]

  AttrReaders.each { |meth| define_method(meth) { @data[meth.to_s] } }

  attr_reader :data

  def initialize(country_data)
    @data = country_data.is_a?(Hash) ? country_data : Data[country_data]
  end

  def valid?
    !(@data.nil? || @data.empty?)
  end

  alias_method :zip, :postal_code
  alias_method :zip?, :postal_code
  alias_method :postal_code?, :postal_code

  def ==(other)
    other == data
  end

  def in_eu?
    @data['eu_member'].nil? ? false : @data['eu_member']
  end

  def to_s
    @data['name']
  end

  private

  class << self
    def new(country_data)
      if country_data.is_a?(Hash) || Data.keys.include?(country_data = country_data.to_s.tap(&:upcase!))
        super(country_data)
      end
    end

    # def all(&blk)
    #   blk ||= proc { |country, data| [data['name'], country] }
    #   Data.map(&blk)
    # end

    def search(query)
      country = new(query)
      (country && country.valid?) ? country : nil
    end

    def [](query)
      search(query)
    end

    # def method_missing(*m)
    #   regex = m.first.to_s.match(/^find_(all_)?(country_|countries_)?by_(.+)/)
    #   super unless regex
    #
    #   countries = find_by(Regexp.last_match[3], m[1], Regexp.last_match[2])
    #   Regexp.last_match[1] ? countries : countries.last
    # end
    #
    # def find_all_by(attribute, val)
    #   attributes, value = parse_attributes(attribute, val)
    #
    #   Data.select do |_, v|
    #     attributes.map do |attr|
    #       Array(v[attr]).any? { |n| value === n.to_s.downcase }
    #     end.include?(true)
    #   end
    # end
    #
    # protected
    #
    # def parse_attributes(attribute, val)
    #   fail "Invalid attribute name '#{attribute}'" unless instance_methods.include?(attribute.to_sym)
    #
    #   attributes = Array(attribute.to_s)
    #   if attributes == ['name']
    #     attributes << 'names'
    #     # TODO: Revisit when better data from i18n_data
    #     # attributes << 'translated_names'
    #   end
    #
    #   val = (val.is_a?(Regexp) ? Regexp.new(val.source, 'i') : val.to_s.downcase)
    #
    #   [attributes, val]
    # end
    #
    # def find_by(attribute, value, obj = nil)
    #   find_all_by(attribute.downcase, value).map do |country|
    #     obj.nil? ? country : new(country.last)
    #   end
    # end
  end
end

# def ISO3166::Country(country_data_or_country)
#   case country_data_or_country
#   when ISO3166::Country
#     country_data_or_country
#   when String, Symbol
#     ISO3166::Country.search(country_data_or_country)
#   else
#     fail TypeError, "can't convert #{country_data_or_country.class.name} into ISO3166::Country"
#   end
# end
