# frozen_string_literal: true
describe ArtsController, type: :routing do
  describe 'routing' do
    it 'routes to #index' do
      expect('/arts').to eq('/arts')
    end

    it 'routes to #new' do
      expect('/arts/new').to eq('/arts/new')
    end

    it 'routes to #show' do
      expect('/arts/1').to eq('/arts/1')
    end

    it 'routes to #edit' do
      expect('/arts/1/edit').to eq('/arts/1/edit')
    end

    it 'routes to #create' do
      expect(post: '/arts').to eq({post: '/arts'})
    end

    it 'routes to #update' do
      expect(put: '/arts/1').to eq({put: '/arts/1'})
    end

    it 'routes to #destroy' do
      expect(delete: '/arts/1').to eq({delete: '/arts/1'})
    end

    it { expect(get: '/arts').to eq({get: '/arts'}) }

    describe :helpers do
      it { expect(get: '/arts').to eq({get: '/arts'}) }
    end
  end
end
