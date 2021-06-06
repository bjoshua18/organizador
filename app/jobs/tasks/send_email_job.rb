class Tasks::SendEmailJob
  include SuckerPunch::Job

  def perform(task_id) # Pasar solo tipos planos (int, string) por problemas de serialización
    task = Task.find(task_id)
    Tasks::SendEmail.new.call task
  end
end
