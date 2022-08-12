require 'rails_helper'

RSpec.describe Client, type: :model do
  subject { described_class.new(name: 'Cliente01', nit: 123, company_id: company.id) }
  let(:company) { Company.create!(name: 'Codify', nit: '123', address: 'Anywhere') }
  
  describe 'with valid values' do
    it 'is valid' do
      expect(subject).to be_valid
    end
  end

  describe 'with invalid values' do
    describe 'with no name' do
      subject { described_class.new(nit: '123', company_id: company.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end

  describe 'with invalid values' do
    describe 'with no nit' do
      subject { described_class.new(name: 'Cliente01', company_id: company.id) }

      it 'is invalid' do
        expect(subject).to_not be_valid
      end
    end
  end

  # describe 'validation of numerical data in the nit' do
  #   it { subject.to validate_numericality_of(:nit).is_greater_than(0).only_integer }
  # end

end
