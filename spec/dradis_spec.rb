require 'dockerspec'
require 'dockerspec/serverspec'
require 'dockerspec/infrataster'

describe docker_build('.', tag: 'zuazo/dradis') do
  it { should have_workdir '/opt/dradis' }
  it { should have_expose '3000' }
  it { should have_entrypoint %w(/entrypoint.sh) }

  describe docker_build('spec/', tag: 'zuazo/dradis_test') do
    docker_env = { 'SECRET_KEY_BASE' => 'secret' }
    describe docker_run('zuazo/dradis_test', env: docker_env) do
      before(:all) { sleep(10) } if ENV['TRAVIS']

      describe package('nodejs') do
        it { should be_installed }
      end

      it 'has node in the path' do
        expect(command('which node || which nodejs').exit_status).to eq 0
      end

      describe process('su -m -l dradis -c exec bundle exec rails server') do
        it { should be_running }
      end

      describe port('3000') do
        it { should be_listening }
      end

      describe server(described_container) do
        describe http('http://localhost:3000/setup') do
          it 'contains "Dradis"' do
            expect(response.body).to match(/Dradis/i)
          end

          it 'does not contain "Oops"' do
            expect(response.body).to_not match(/Oops/i)
          end
        end

        describe capybara('http://localhost:3000') do
          let(:password) { '4dm1np4ssw0rd' }

          describe 'on /setup' do
            before { visit '/setup' }

            it 'contains "Configure the shared password"' do
              expect(page).to have_content 'Configure the shared password'
            end

            it 'sets up admin password' do
              fill_in 'Password', with: password
              fill_in 'Confirm Password', with: password
              click_button 'Set password and continue'
            end
          end
          
          describe 'on /session/new' do
            before { visit '/session/new' }

            it 'logs in as admin' do
              expect(page).to have_content 'Welcome, please sign in'
              fill_in 'User name', with: 'admin'
              fill_in 'Password', with: password
              click_button 'Let me in!'
            end
          end

          describe 'on /' do
            before { visit '/' }

            it 'is logged id' do
              expect(page).to have_content 'PROJECT SUMMARY'
            end
          end
        end
      end
    end
  end
end
