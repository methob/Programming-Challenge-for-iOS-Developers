
import UIKit



class TesteViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, MediaFilesServiceDelegate {

    var medias: [Media] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var coisando: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.startActivityIndicator()
        MediaFilesService(delegate: self).requestMediaFiles()
        
        tableView.register(UINib(nibName: "MediaFilesTableViewCell", bundle: nil), forCellReuseIdentifier: "mediaFileCell")
        
        tableView.estimatedRowHeight = 40
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return medias.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "mediaFileCell", for: indexPath) as! MediaFilesTableViewCell
        
        let media = medias[(indexPath as NSIndexPath).row]
        
        cell.name.text = media.name
        cell.imageName.text = media.image
        
        return cell
    }
    
    func requestMediaFilesSuccessful(dataAssets: DataAssets?) {
        
        medias = (dataAssets?.medias!)!
        stopActivityIndicator()
        self.tableView.reloadData()
    }
    
    func requestMediaFilesFailed(data: Data?) {
        showAlertView(title: "errado", message: "deu ruim")
        stopActivityIndicator()
    }
    
    
    @IBAction func ViewClick(_ sender: Any) {
        
    }
    
}

