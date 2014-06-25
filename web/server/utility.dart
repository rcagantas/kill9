part of giggl;

abstract class Observer {
  void onNotify(Object data, int event);
}

class Subject {

  List<Observer> _observers = new List();

  void addObserver(Observer observer) {
    _observers.add(observer);
  }

  void removeObserver(Observer observer) {
    _observers.remove(observer);
  }

  void notify(Object data, int event) {
    _observers.forEach((observer)=>observer.onNotify(data, event));
  }
}