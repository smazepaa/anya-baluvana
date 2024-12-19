import UIKit
import SnapKit
import MapKit

final class OrderFooterView: UIView {
    let paymentSegmentedControl = UISegmentedControl(items: ["Cash", "Card"])
    let mapView = MKMapView()
    let addressTextField = UITextField()
    let confirmButton = UIButton(type: .system)
    private let geocoder = CLGeocoder()

    var onConfirmTapped: (() -> Void)?

    init() {
        super.init(frame: .zero)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupViews() {
        backgroundColor = .white
        layer.borderColor = UIColor.lightGray.cgColor
        layer.borderWidth = 1
        
        paymentSegmentedControl.selectedSegmentIndex = 0
        addressTextField.placeholder = "Enter delivery address manually"
        addressTextField.borderStyle = .roundedRect
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleMapTap(_:)))
        mapView.addGestureRecognizer(longPressGesture)
        mapView.layer.cornerRadius = 8
        mapView.delegate = self
        mapView.delegate = self

        confirmButton.setTitle("Confirm Order", for: .normal)
        confirmButton.titleLabel?.font = .boldSystemFont(ofSize: 18)
        confirmButton.backgroundColor = .systemPink
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 8
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)

        addSubviews(paymentSegmentedControl, mapView, addressTextField, confirmButton)
        setupLayout()
    }

    private func setupLayout() {
        paymentSegmentedControl.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        mapView.snp.makeConstraints {
            $0.top.equalTo(paymentSegmentedControl.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(180)
        }

        addressTextField.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }

        confirmButton.snp.makeConstraints {
            $0.top.equalTo(addressTextField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(50)
            $0.bottom.equalToSuperview().inset(16)
        }
    }

    @objc private func confirmTapped() {
        onConfirmTapped?()
    }
    
    @objc private func handleMapTap(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let location = gesture.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            mapView.removeAnnotations(mapView.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "Selected Location"
            mapView.addAnnotation(annotation)
            reverseGeocode(coordinate: coordinate)
        }
    }
    
    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                self?.addressTextField.text = "Unable to find address"
                return
            }
            if let placemark = placemarks?.first {
                let street = placemark.thoroughfare ?? ""
                let number = placemark.subThoroughfare ?? ""
                let city = placemark.locality ?? ""
                let address = "\(street) \(number), \(city)"
                
                DispatchQueue.main.async {
                    self?.addressTextField.text = address
                }
            } else {
                DispatchQueue.main.async {
                    self?.addressTextField.text = "Address not found"
                }
            }
        }
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
}

extension OrderFooterView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "DraggablePin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.isDraggable = true
            annotationView?.animatesDrop = true
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}
