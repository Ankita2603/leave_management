import consumer from "./consumer"

consumer.subscriptions.create("LeaveChannel", {
  connected() {
    console.log("✅ Subscribed to LeaveChannel");
  },
  received(data) {
    console.log("📡 Received update via ActionCable:", data);
    // You can also update DOM here
  }
});
