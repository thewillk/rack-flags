require_relative 'spec_helper'

module TeeDub module FeatureFlags

  describe Reader do
    def derived_flags_final_values(derived_flags)
      derived_flags.map { |flag| flag.final_value }
    end

    def full_flags_overrides(derived_flags)
      derived_flags.map { |flag| flag.override }
    end

    let( :base_flags ) do
      [
        BaseFlag.new( :usually_on, 'a flag', true ),
        BaseFlag.new( :usually_off, 'another flag', false )
      ]
    end
    let( :overrides ){ {} }

    subject( :reader ){ Reader.new( base_flags, overrides ) }

    shared_examples 'full flags that mimic the base flags' do
      it 'has a name, description, and default for each base flag' do
        full_flags = subject.full_flags

        expect(full_flags.length).to eq(base_flags.length)

        expect(full_flags[0].name).to eq(:usually_on)
        expect(full_flags[0].description).to eq('a flag')
        expect(full_flags[0].default).to be_true

        expect(full_flags[1].name).to eq(:usually_off)
        expect(full_flags[1].description).to eq('another flag')
        expect(full_flags[1].default).to be_false
      end

    end

    context 'no overrides' do
      let( :overrides ){ {} }

      its(:base_flags){ should == {usually_on: true, usually_off: false} }

      specify 'on? is true for a flag which is on by default' do
        subject.on?( :usually_on ).should be_true
      end

      specify 'on? is false for a flag which is off by default' do
        subject.on?( :usually_off ).should be_false
      end

      specify 'on? is false for unknown flags' do
        subject.on?( :unknown_flag ).should be_false
      end

      it_behaves_like 'full flags that mimic the base flags'

      it 'has derived flags with nil override values' do
        overrides = full_flags_overrides(subject.full_flags)

        expect(overrides).to eq([nil, nil])
      end
    end

    context 'overridden to false' do
      let( :overrides ){ {usually_on: false} }

      specify 'on? is false' do
        subject.on?( :usually_on ).should be_false
      end

      it_behaves_like 'full flags that mimic the base flags'

      it 'has full flags with one override value' do
        overrides = full_flags_overrides(subject.full_flags)

        expect(overrides).to eq([false, nil])
      end
    end

    context 'overridding a flag which has no base' do
      let( :overrides ){ {no_base: true} }

      specify 'on? is false' do
        subject.on?( :no_base ).should be_false
      end

      it_behaves_like 'full flags that mimic the base flags'

      it 'has full flags with no override values' do
        overrides = full_flags_overrides(subject.full_flags)

        expect(overrides).to eq([nil, nil])
      end
    end
  end

end end
