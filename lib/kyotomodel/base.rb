require 'supermodel'
module KyotoModel
  class RecordNotFound < StandardError; end
  
  class Base < SuperModel::Base
    
    class << self
      attr_accessor :db_name
      
      def set_db name
        db_name = name
      end
      
      def db
        KyotoModel.databases[db_name || :default]
      end
      
      def namespace
        @namespace ||= "KyotoModel::#{self.name}"
      end
      
      def namespace=(namespace)
        @namespace = namespace
      end
      
      def kyoto_key(id)
        "#{namespace}::#{id}"
      end
      
      def find(*ids)
        keys = ids.map { |i| kyoto_key(i) }
        res = bulk_request(keys)
        objs = res.reduce([]) do |list, (k,v)|
          list << existing(v)
        end
        
        if objs.length != ids.length 
          error = "Couldn't find all #{self.name.pluralize} with IDs "
          error << "(#{ids.join(", ")}) (found #{objs.length} results, but was looking for #{ids.length})"
          raise(RecordNotFound, error)
        end
        
        objs
      end
      
      def first
        raise "Not implemented"      
      end
      
      def last
        raise "Not implemented"       
      end
      
      def exists?(id)
        db.get(kyoto_key(id)) && true || false
      end
      
      def count
        db.match_prefix("#{namespace}::").length
      end
      
      def all
        bulk_request(db.match_prefix("#{namespace}::")).
        map do |k,v|
          existing(v)
        end
      end
      
      def select
        raise "Not implemented"
      end
      
      def delete_all
        db.clear
      end
      
      def create(attributes = nil, options = {}, &block)
        if attributes.is_a?(Array)
          attributes.collect { |attr| create(attr, options, &block) }
        else
          object = new(attributes, options)
          yield(object) if block_given?
          object.save
          object
        end
      end

      def create!(attributes = nil, options = {}, &block)
        if attributes.is_a?(Array)
          attributes.collect { |attr| create!(attr, options, &block) }
        else
          object = new(attributes, options)
          yield(object) if block_given?
          object.save!
          object
        end
      end
      
      protected
        def from_ids(ids)
          ids.map {|id| existing(:id => id) }
        end
        
        def existing(atts = {})
          item = self.new(atts)
          item.new_record = false
          item
        end
        
        def bulk_request(keys)
          bulk = db.get_bulk(keys)
          bulk.delete("num")
          bulk
        end
    end
    
    def initialize(attributes = {})
      @new_record = true
      @attributes = {}.with_indifferent_access
      @attributes.merge!(known_attributes.inject({}) {|h, n| h[n] = nil; h })
      @changed_attributes = {}
      load(attributes)
      yield self if block_given?
    end
    
    def save
      self.id = self.class.db.increment("#{self.class.namespace}::next_id") if @new_record
      self.class.db.set(kyoto_key, serializable_hash)
    end
    
    def save!
      save || raise(InvalidRecord)
    end
    
    protected
      def kyoto_key
        self.class.kyoto_key(id)
      end
    
  end
end
