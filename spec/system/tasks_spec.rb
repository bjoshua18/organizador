require 'rails_helper'

RSpec.describe "Tasks", type: :system do
  let(:user) { create :user }
  before(:each) { sign_in user }

  describe 'GET /tasks' do
    it 'has a correct title' do
      visit '/tasks'

      expect(page).to have_content 'Lista de Tareas'
    end
  end

  describe 'POST /tasks' do
    let!(:category) { create :category }
    let!(:participant) { create :user }

    it 'creates a new task', js: true do
      visit '/tasks/new'

      fill_in 'task[name]', with: 'Test 234'
      fill_in 'task[description]', with: 'Testing'
      fill_in 'task[due_date]', with: Date.today + 5.days
      # select category.name, from: 'task[category_id]'
      page.execute_script(
        "document.getElementById('task_category_id').selectize.setValue('#{category.id}')"
      )
      
      click_link 'Agregar un participante'
      
      # xpath = //*[@id="addParticipants"]/div/div[1]
      # within(:xpath, xpath) do
      #   select participant.email, from: 'Usuario'
      #   select 'responsible', from: 'Rol'
      # end
      page.execute_script(
        "document.querySelector('.selectize.responsible').selectize.setValue('#{participant.id}')"
      )
      page.execute_script(
        "document.querySelector('.selectize.role').selectize.setValue('1')"
      )

      click_button 'Crear Task'

      expect(page).to have_content('Task was successfully created.')
    end
  end
end
