import consumer from "./consumer"

consumer.subscriptions.create("LeaveChannel", {
  received(data) {
    const row = document.getElementById(`leave-${data.leave_id}`)
    if (row) {
      row.classList.add(data.edited ? 'table-warning' : 'table-success')
    }
  }
})
