function(doc) {
  if (doc.class == 'job' && doc.state == 'complete') {
    emit(doc.completed_at, doc);
  }
}