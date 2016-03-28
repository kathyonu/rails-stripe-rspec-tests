# frozen_string_literal: true
describe UsersController, type: :routing do
  describe 'routing' do
    it 'routes to root_path' do
      expect(get('visitors/index')).to route_to('visitors#index')
    end

    # tests app/views/profile/index.html.slim 
    it 'routes to profile#index' do
      expect(get('/profile/index')).to route_to('profile#index')
    end

    # tests app/views/profile/user
    it 'routes to users#profile' do
      expect(get('/users/profile')).to route_to('users#profile')
    end

    it 'routes to users#login' do
      expect(post('/users/login')).to route_to('devise/sessions#create')
    end

    it 'routes to visitors#index' do
      expect(get('/visitors/index')).to route_to('visitors#index')
    end

    it 'routes to visitors#team' do
      expect(get('/visitors/team')).to route_to('visitors#team')
    end

    it 'routes to products#index' do
      pending 'needs work to pass'
      expect(get('/products/show/index]')).to route_to('products#index')
    end

    it 'routes to pages#about' do
      pending 'needs work to pass'
      expect(get('/about')).to route_to('pages#about')
    end

    it 'routes to users#omniauth_callbacks' do
      pending 'needs work to pass'
      expect(get('/users/omniauth_callbacks')).to route_to('users#omniauth_callbacks')
    end
  end
end
