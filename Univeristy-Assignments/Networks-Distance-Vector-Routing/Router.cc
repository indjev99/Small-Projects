#include <stdio.h>
#include <omnetpp.h>

#include "Router.h"

Define_Module(Router);

using namespace std;


// functions from the cModule interface

void Router::initialize() {
  // set the infinity value
  INF = par("smallInfinity");
  if (INF <= 0) INF = INFINITE_ROUTE_COST;

  // initialise a zero-route for this router to itself
  Route selfRoute;
  selfRoute.dest = getName();
  selfRoute.nextHop = getName();
  selfRoute.cost = 0.0;
  routes[getName()] = selfRoute;

  // setup the internal activity messages
  periodic_update_activity = 
    new cMessage("Periodic update to neighbours.");
  scheduleAt(simTime() + par("periodicUpdateInterval"), periodic_update_activity);

  message_sending_activity = 
    new cMessage("Periodic sending of message to other router.");
  string messageTo = par("messageTo");
  if (messageTo != "") {
    scheduleAt(simTime() + par("messageSendingInterval"), message_sending_activity);
  }

  check_alive_activity =
    new cMessage("Periodic checking of neighbours being alive.");
  scheduleAt(simTime() + par("checkAliveInterval"), check_alive_activity);

}

void Router::finish() {
  printRoutingTable();

  // delete internal activity messages
  cancelEvent(periodic_update_activity);
  delete periodic_update_activity;
  cancelEvent(message_sending_activity);
  delete(message_sending_activity);
  cancelEvent(check_alive_activity);
  delete(check_alive_activity);
}

void Router::handleMessage(cMessage *msg) {
  if (simTime() > par("diesAt")) {
    // if router has died, do nothing.
    if (msg != periodic_update_activity && 
        msg != message_sending_activity &&
        msg != check_alive_activity) {
      // don't delete the above messages because we reuse them.
      // do delete messages coming from other routers.
      delete msg;
    }
    return;
  } else if (msg == check_alive_activity) {
    checkAliveActivity();
    scheduleAt(simTime() + par("checkAliveInterval"), check_alive_activity);

  } else if (msg == periodic_update_activity) {
    sendRoutingUpdatesActivity();
    scheduleAt(simTime() + par("periodicUpdateInterval"), periodic_update_activity);

  } else if (msg == message_sending_activity) {
    sendMessageToOtherRouterActivity(par("messageTo"));
    scheduleAt(simTime() + par("messageSendingInterval"), message_sending_activity);

  } else {
    // non-internal messages
    if (msg->getKind() == UPDATE_PACKET) {
      updateRoutesActivity((UpdatePacket*) msg);
      lastSeen[msg->getSenderModule()->getName()] = msg->getSendingTime();
    } else if (msg->getKind() == MESSAGE_PACKET) {
      MessagePacket* p = (MessagePacket*) msg;
      EV << '@' << getName()
         << ": Message " << p->getId()
         << " arrived from " << p->getSource()
         << " for " << p->getDestination() << endl;

      forwardMessage(p->getDestination(), p->getData());
    }
    delete msg;
  }
}


// utility functions

void Router::printRoutingTable() {
  EV << '@' << getName() << ": Routing table:" << endl;
  for (map<string, Route>::iterator r = routes.begin(); r != routes.end(); ++r) {
    EV << "--" << r->second.nextHop << "--> " << r->second.dest
       << ": " <<  r->second.cost << endl;
  }
  EV << endl;
}

void Router::sendCost(string dest) {
  if (routes.find(dest) != routes.end()) {
    Route r = routes.find(dest)->second;

    // iterate over all output gates of this router
    for (int i=0; i < gateSize("out"); i++) {
      cGate *g = gate("out", i);

      // Whether we are trying to send back to the next hop of the route
      bool backSending = g->getNextGate()->getOwnerModule()->getName() == r.nextHop;

      // Split Horizon doesn't allow this
      if (par("useSplitHorizon") && backSending) {
        continue;
      }

      UpdatePacket* p = new UpdatePacket("", UPDATE_PACKET);
      p->setSource(getName());
      p->setDestination(dest.c_str());

      // Poison Reverse makes us advertise an infinite route instead
      if (par("usePoisonReverse") && backSending) {
        p->setCost(INF);
      } else {
        p->setCost(r.cost);
      }

      send(p, g);
    }
  } else {
    EV << "Error: Request to send cost to unknown router." << endl;
  }
}

cGate* Router::findGateForNeighbour(string n) {
  for (int i=0; i < gateSize("out"); i++) {
    cGate *g = gate("out", i);
    if (g->getNextGate()->getOwnerModule()->getName() == n) {
      return g;
    }
  }

  EV << "@" << getName() << ": NO_GATE. Cannot find out gate for router "
     << n << endl;
  return NULL;
}

void Router::forwardMessage(string dest, string data) {
  if (dest == getName()) {
    // We are the intended recipient
    EV << "@" << getName() << ": Accepting message: ["
       << data << "]" << endl;
  } else {
    // We need to forward the message
    if (routes.find(dest) != routes.end() && routes.find(dest)->second.cost < INF) {
      // There is a valid path
      MessagePacket* p = new MessagePacket("", MESSAGE_PACKET);
      p->setSource(getName());
      p->setDestination(dest.c_str());
      p->setData(data.c_str());
      send(p, findGateForNeighbour(routes.find(dest)->second.nextHop));
    } else {
      EV << "@" << getName() << ": Dropped message for "
         << dest << ": ["  << data << "]" << endl;
    }
  }
}



// activity functions

void Router::sendRoutingUpdatesActivity() {
  // advertise my routing table to all neighbours
  for (map<string, Route>::iterator r = routes.begin(); r != routes.end(); ++r) {
    sendCost(r->first);
  }
}

void Router::checkAliveActivity() {
  for (map<string, simtime_t>::iterator ls = lastSeen.begin(); 
       ls != lastSeen.end(); ) {
    if (simTime() - ls->second > par("peerFailedTimeOut")) {
      EV << "@" << getName() << ": neighbour " << ls->first << " failed" << endl;
      // Neighbour has not been seen recently and is considered failed
      // Update the routing table accordingly and inform the neighbours

      for (map<string, Route>::iterator r = routes.begin(); r != routes.end(); ++r) {
        if (r->second.nextHop == ls->first) {
          r->second.cost = INF;
          sendCost(r->first);
        }
      }

      // remove the entry in the mapping, so the failure is not reported again
      lastSeen.erase(ls++);
    } else {
      ls++;
    }
  }
}

void Router::updateRoutesActivity(UpdatePacket* p) {
  Route newRoute;
  newRoute.dest = p->getDestination();
  newRoute.nextHop = p->getSource();
  // The cost is capped at infinity
  newRoute.cost = min(p->getCost() + 1, INF);

  EV << "@" << getName() << ": Received update from " << p->getSource()
     << ". route " << newRoute.nextHop << " --> " << newRoute.dest
     << ", cost " << newRoute.cost << endl;

  if (routes.find(newRoute.dest) != routes.end()) {
    Route r = routes.find(newRoute.dest)->second;
    if ((r.nextHop != newRoute.nextHop && r.cost <= newRoute.cost) ||
        (r.nextHop == newRoute.nextHop && r.cost == newRoute.cost)) {
      // The new route is useless
      return;
    }
  }

  EV << "@" << getName() << ": Updating route "
     << "--" << newRoute.nextHop << "--> " << newRoute.dest
     << ": " << newRoute.cost << endl;

  routes[newRoute.dest] = newRoute;
  sendCost(newRoute.dest);
}

void Router::sendMessageToOtherRouterActivity(string dest) {
  char data[100];
  snprintf(data, 100, "This is a message from %s to %s.", getName(), dest.c_str());
  forwardMessage(dest, data);
}
