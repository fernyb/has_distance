require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Store" do
  before :all do
    @default_config = Store.distance_config.clone
    Store.send(:alias_method, :lat, :latitude)
    Store.send(:alias_method, :lon, :longitude)
  end

  before :each do
    Store.distance_config = @default_config.clone
  end

  context :has_distance do
    context :defaults do
      it 'latitude name' do
        Store.distance_config.lat_name.should == 'latitude'
      end

      it 'longitude name' do
        Store.distance_config.lng_name.should == 'longitude'
      end

      it 'limit' do
        Store.distance_config.limit.should == 12
      end

      it 'distance' do
        Store.distance_config.distance.should == 20
      end

      it 'units' do
        Store.distance_config.units.should == :miles
      end

      it 'column_name' do
        Store.distance_config.column_name.should == :distance
      end
    end

    it 'returns store' do
      Store.all.size.should > 0
    end

    it 'responds to has_distance' do
      Store.should respond_to(:has_distance)
    end

    it 'can be configured with a block' do
      Store.has_distance :distance do |config|
        config.limit = 2
      end
      Store.first.nearby.to_sql.should =~ /LIMIT 2/
    end

    it 'can specify latitude name' do
      Store.distance_config.lat_name = "lat"
      Store.first.nearby.to_sql.should =~ /\(lat\)/
    end

    it 'can specify longitude name' do
      Store.distance_config.lng_name = "lon"
      Store.first.nearby.to_sql.should =~ /\(lon\)/
    end

    it 'can specificy the distance column name' do
      Store.distance_config.column_name = 'dist'
      Store.first.nearby.to_sql.should =~ /AS dist FROM/
    end

    it 'can configure column name' do
      Store.has_distance :dist do |config|
        config.column_name = :name
      end
      Store.distance_config.column_name.should == :name
    end

    it 'can configure latitude name' do
      Store.has_distance :dist do |config|
        config.lat_name = 'lat'
      end
      Store.distance_config.lat_name.should == 'lat'
    end

    it 'can configure longitude name' do
      Store.has_distance :dist do |config|
        config.lng_name = 'lon'
      end
      Store.distance_config.lng_name.should == 'lon'
    end

    it 'can configure distance' do
      Store.has_distance :dist do |config|
        config.distance = 4
      end
      Store.distance_config.distance.should == 4
    end

    it 'can configure limit' do
      Store.has_distance :dist do |config|
        config.limit = 3
      end
      Store.distance_config.limit.should == 3
    end
  end

  context :nearby do
    it 'generates sql for miles units' do
      sql = Store.first.nearby.to_sql
      sql.should == "SELECT  *, 
            (ACOS(least(1,COS(0.5953003919287299)*COS(-2.0620890579387803)*COS(RADIANS(latitude))*COS(RADIANS(longitude))+
            COS(0.5953003919287299)*SIN(-2.0620890579387803)*COS(RADIANS(latitude))*SIN(RADIANS(longitude))+
            SIN(0.5953003919287299)*SIN(RADIANS(latitude))))*3963.19)
            AS distance FROM \"stores\" GROUP BY id HAVING distance <= 20 LIMIT 12"
    end

    it 'generates sql for kms units' do
      Store.distance_config.units = :kms
      sql = Store.first.nearby.to_sql
      sql.should == 'SELECT  *, 
            (ACOS(least(1,COS(0.5953003919287299)*COS(-2.0620890579387803)*COS(RADIANS(latitude))*COS(RADIANS(longitude))+
            COS(0.5953003919287299)*SIN(-2.0620890579387803)*COS(RADIANS(latitude))*SIN(RADIANS(longitude))+
            SIN(0.5953003919287299)*SIN(RADIANS(latitude))))*6376.77271)
            AS distance FROM "stores" GROUP BY id HAVING distance <= 20 LIMIT 12'
    end

    it 'generates sql for nms units' do
      Store.distance_config.units = :nms
      sql = Store.first.nearby.to_sql
      sql.should == 'SELECT  *, 
            (ACOS(least(1,COS(0.5953003919287299)*COS(-2.0620890579387803)*COS(RADIANS(latitude))*COS(RADIANS(longitude))+
            COS(0.5953003919287299)*SIN(-2.0620890579387803)*COS(RADIANS(latitude))*SIN(RADIANS(longitude))+
            SIN(0.5953003919287299)*SIN(RADIANS(latitude))))*3443.91795253198)
            AS distance FROM "stores" GROUP BY id HAVING distance <= 20 LIMIT 12'
    end

    it 'uses miles as default units' do
      Store.distance_config.units.should == :miles
    end

    it 'has distance column_name for nearby results' do
      stores = Store.first.nearby.limit(2)
      stores.each do |store|
        store.should respond_to(:distance)
      end

      stores[0].distance.should == 0.0
      stores[1].distance.should == 1.931497125999382
    end

    it 'distance name can be changed' do
      Store.has_distance :distname
      stores = Store.first.nearby.limit(2)
      stores.each do |store|
        store.should respond_to(:distname)
        store.should_not respond_to(:distance)
      end

      stores[0].distname.should == 0.0
      stores[1].distname.should == 1.931497125999382
    end

    it 'can be chained' do
      sql = Store.first.nearby.limit(6).to_sql
      sql.should =~ /LIMIT 6/
    end

    it 'responds to nearby' do
      Store.first.should respond_to(:nearby)
    end

    it 'can limit results' do
      sql = Store.first.nearby(limit: 5).to_sql
      sql.should =~ /LIMIT 5/
    end

    it 'can limit by distance' do
      sql = Store.first.nearby(distance: 8).to_sql
      sql.should =~ /HAVING distance <= 8/
    end
  end

end
